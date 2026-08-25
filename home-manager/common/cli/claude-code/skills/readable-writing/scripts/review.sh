#!/usr/bin/env bash
# 観点ごとに claude -p を並列で起動し、findings を1つのJSON配列にまとめて標準出力に出す。
set -euo pipefail

usage() {
    cat >&2 <<'EOF'
usage: review.sh <target-file> [ja|en|both]

第2引数を省いた場合、対象の文章の文字種から言語を判定する。
標準出力に findings のJSON配列を出す。
EOF
    exit 2
}

[ $# -ge 1 ] && [ $# -le 2 ] || usage

target=$1
[ -f "$target" ] || { echo "review.sh: no such file: $target" >&2; exit 1; }

for cmd in claude jq perl awk; do
    command -v "$cmd" >/dev/null || { echo "review.sh: $cmd not found on PATH" >&2; exit 1; }
done

skill_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
policies="$skill_dir/policies"

if [ $# -eq 2 ]; then
    lang=$2
else
    lang=$(perl -CSD -ne '
        $j += () = /\p{Hiragana}|\p{Katakana}|\p{Han}/g;
        $t += length;
        END { print( ($t && $j / $t >= 0.05) ? "ja" : "en" ) }
    ' "$target")
fi

case "$lang" in
    ja) lang_dirs="ja" ;;
    en) lang_dirs="en" ;;
    both) lang_dirs="ja en" ;;
    *) echo "review.sh: unknown language: $lang" >&2; exit 1 ;;
esac

perspectives='立場|stance|書き手が何を引き受けているか
主体|agency|誰が何をしたか
箇条書き|lists|箇条書きの階層と粒度
文書構成|document|見出し、節、情報の取捨
修辞|rhetoric|構文の型とリズム
語彙|vocabulary|語の選択
記号|symbols|記号と字面'

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

awk '{ printf "%d\t%s\n", NR, $0 }' "$target" > "$tmp/numbered"

policy_files() {
    local key=$1 dir file
    for dir in common $lang_dirs; do
        file="$policies/$dir/$key.md"
        [ -f "$file" ] && printf '%s\n' "$file"
    done
    return 0
}

build_prompt() {
    local desc=$1 files=$2 out=$3 file dir

    {
        printf 'あなたは文章レビュアーである。%sを見る。\n\n' "$desc"

        printf '# ポリシー\n\n'
        while IFS= read -r file; do
            dir=$(basename "$(dirname "$file")")
            printf '## %s/%s\n\n' "$dir" "$(basename "$file")"
            cat "$file"
            printf '\n'
        done <<< "$files"

        printf '# 本文\n\n行番号とタブ区切りで渡す。番号自体は本文に含まれない。\n\n'
        cat "$tmp/numbered"
        printf '\n'

        cat <<'RULES'
# 判定ルール

- `common/` はパターンと直し方を持つ
- `ja/` と `en/` はその言語の言い回しと例を持つ
- 両方を突き合わせて判定する
- 1つの文書に日本語と英語が混ざる場合
    - 箇所ごとに言語を判定する
- コードブロックの中身
    - 対象にしない
- `AI版` `Before` の見出しの下
    - 意図的な例として扱う
    - 指摘しない
- 渡されたポリシーで説明できるものだけを指摘する
- 同じ形が3箇所以上に出る場合
    - 代表1件にまとめる
    - 他の該当行を `line` に列挙する

# 出力ルール

JSON配列だけを出力する。前置き、要約、良い点、コードフェンス、説明を書かない。指摘がなければ `[]` だけを出力する。

[
  {
    "line": <行番号、または範囲を表す文字列 "12-18">,
    "quote": "<該当箇所の原文をそのまま>",
    "category": "<ポリシー内の該当節名>",
    "problem": "<何が読みにくいか1文>",
    "fix": "<書き換えた後の文そのもの>"
  }
]

`quote` は本文に実在する文字列をそのまま入れる。要約しない。
`fix` は書き換え案の文そのものを入れる。直し方の説明を入れない。
RULES
    } > "$out"
}

running=""
while IFS='|' read -r name key desc; do
    files=$(policy_files "$key")
    [ -n "$files" ] || { echo "review.sh: no policy file for $key" >&2; exit 1; }

    build_prompt "$desc" "$files" "$tmp/prompt.$key"
    claude -p "$(cat "$tmp/prompt.$key")" < /dev/null > "$tmp/out.$key" 2> "$tmp/err.$key" &
    running="$running $!:$key"
done <<< "$perspectives"

expected=$(printf '%s\n' "$perspectives" | wc -l | tr -d ' ')
started=$(printf '%s' "$running" | wc -w | tr -d ' ')
[ "$started" -eq "$expected" ] || {
    echo "review.sh: started $started of $expected reviewers" >&2
    exit 1
}

failed=0
for entry in $running; do
    pid=${entry%%:*}
    key=${entry##*:}
    if ! wait "$pid"; then
        echo "review.sh: claude failed for $key" >&2
        cat "$tmp/err.$key" >&2
        failed=1
    fi
done
[ "$failed" -eq 0 ] || exit 1

while IFS='|' read -r name key desc; do
    body=$(perl -0777 -ne 'print $1 if /(\[.*\])/s' "$tmp/out.$key")
    [ -n "$body" ] || {
        echo "review.sh: $key returned no JSON array" >&2
        cat "$tmp/out.$key" "$tmp/err.$key" >&2
        exit 1
    }
    printf '%s' "$body" \
        | jq --arg p "$name" --arg f "$target" 'map({file: $f, perspective: $p} + del(.file))' > "$tmp/json.$key" || {
            echo "review.sh: $key returned output that is not a JSON array" >&2
            cat "$tmp/out.$key" >&2
            exit 1
        }
done <<< "$perspectives"

jq -s 'add | sort_by(.line)' "$tmp"/json.*
