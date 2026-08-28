#!/usr/bin/env bash
# 観点ごとに claude -p を並列で起動し、findings を1つのJSON配列にまとめて標準出力に出す。
set -euo pipefail

usage() {
    cat >&2 <<'EOF'
usage: review.sh <target-file>

対象の文章から言語を判定し、標準出力に findings のJSON配列を出す。
EOF
    exit 2
}

[ $# -eq 1 ] || usage

target=$1
[ -f "$target" ] || { echo "review.sh: no such file: $target" >&2; exit 1; }

for cmd in claude jq perl awk; do
    command -v "$cmd" >/dev/null || { echo "review.sh: $cmd not found on PATH" >&2; exit 1; }
done

skill_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
policies="$skill_dir/policies"

# 日英が混ざる文書には両方のポリシーを渡す。
lang_dirs=$(perl -CSD -ne '
    if (/\p{Hiragana}|\p{Katakana}|\p{Han}/) {
        $ja++;
    } elsif (/[A-Za-z]+(?:\s+[A-Za-z]+){3,}/) {
        $en++;
    }
    END {
        unless ($ja + $en) {
            print STDERR "review.sh: no Japanese or English prose to classify\n";
            exit 1;
        }
        my $min = $ja < $en ? $ja : $en;
        print( $min / ($ja + $en) >= 0.05 ? "ja en" : $ja >= $en ? "ja" : "en" );
    }
' "$target")

# 名前|ファイル名|使うディレクトリ (common / lang / both)|見るもの
perspectives='立場|stance|both|書き手が何を引き受けているか
主体|agency|both|誰が何をしたか
箇条書き|lists|common|箇条書きの階層と粒度
文書構成|document|both|見出し、節、情報の取捨
修辞|rhetoric|both|構文の型とリズム
語彙|vocabulary|lang|語の選択
記号|symbols|both|記号と字面'

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

awk '{ printf "%d\t%s\n", NR, $0 }' "$target" > "$tmp/numbered"

policy_files() {
    local key=$1 scope=$2 dirs dir file
    case "$scope" in
        common) dirs="common" ;;
        lang) dirs="$lang_dirs" ;;
        both) dirs="common $lang_dirs" ;;
        *) echo "review.sh: unknown scope for $key: $scope" >&2; exit 1 ;;
    esac
    for dir in $dirs; do
        file="$policies/$dir/$key.md"
        [ -f "$file" ] || { echo "review.sh: missing policy file: $file" >&2; exit 1; }
        printf '%s\n' "$file"
    done
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
while IFS='|' read -r name key scope desc; do
    files=$(policy_files "$key" "$scope")
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

while IFS='|' read -r name key scope desc; do
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
