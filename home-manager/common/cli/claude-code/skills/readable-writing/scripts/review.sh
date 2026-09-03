#!/usr/bin/env bash
# 観点ごとに `claude -p` を並列で起動し、`findings` を1つのJSON配列にまとめて標準出力に出す。
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

skill_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
policies="$skill_dir/policies"

# 文書の言語を判定して渡すポリシーを決める。日英が混ざる文書には両方を渡す。
lang_dirs=$(nix run nixpkgs#perl -- -CSD -ne '
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

# 名前|ファイル名|見るもの
perspectives='立場|stance|書き手が引き受ける範囲
主体|agency|行為の主体
箇条書き|lists|箇条書きの階層と粒度
文書構成|document|見出し、節、情報の取捨
修辞|rhetoric|構文の型とリズム
語彙|vocabulary|語の選択
記号|symbols|記号と字面'

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

awk '{ printf "%d\t%s\n", NR, $0 }' "$target" > "$tmp/numbered"

nix run nixpkgs#perl -- "$skill_dir/scripts/mechanical.pl" "$lang_dirs" "$target" \
    | jq --arg f "$target" 'map({file: $f} + .)' > "$tmp/json.mechanical"

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

# 各フィールドの入れ方

- `line`
    - 行番号、または範囲を表す `12-18`
- `quote`
    - 本文に実在する文字列をそのまま入れる
    - 要約しない
- `category`
    - ポリシー内の該当節名
- `problem`
    - 何が読みにくいかを1文で
- `fix`
    - 書き換え案の文そのもの
    - 直し方の説明を入れない
RULES
    } > "$out"
}

findings_schema='{
  "type": "object",
  "properties": {
    "findings": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "line": { "type": "string" },
          "quote": { "type": "string" },
          "category": { "type": "string" },
          "problem": { "type": "string" },
          "fix": { "type": ["string", "null"] }
        },
        "required": ["line", "quote", "category", "problem", "fix"],
        "additionalProperties": false
      }
    }
  },
  "required": ["findings"],
  "additionalProperties": false
}'

attempts=3

# claudeが落ちたときと壊れたJSONを返したときに、`attempts` 回まで引き直す。
run_reviewer() {
    local key=$1 attempt=1 delay
    while :; do
        if claude -p "$(cat "$tmp/prompt.$key")" --json-schema "$findings_schema" \
            < /dev/null > "$tmp/out.$key" 2> "$tmp/err.$key" \
            && jq -e . "$tmp/out.$key" > /dev/null 2>&1; then
            return 0
        fi
        [ "$attempt" -lt "$attempts" ] || return 1
        delay=$((5 * attempt ** 2))
        echo "review.sh: $key failed ($attempt/$attempts), retrying in ${delay}s" >&2
        sleep "$delay"
        attempt=$((attempt + 1))
    done
}

running=""
while IFS='|' read -r name key desc; do
    files=$(policy_files "$key")
    [ -n "$files" ] || continue
    build_prompt "$desc" "$files" "$tmp/prompt.$key"
    run_reviewer "$key" &
    running="$running $!:$key:$name"
done <<< "$perspectives"

[ -n "$running" ] || { echo "review.sh: no reviewer started" >&2; exit 1; }

failed=0
for entry in $running; do
    pid=${entry%%:*}
    key=${entry#*:}; key=${key%%:*}
    if ! wait "$pid"; then
        echo "review.sh: claude failed for $key after $attempts attempts" >&2
        cat "$tmp/err.$key" >&2
        failed=1
    fi
done
[ "$failed" -eq 0 ] || exit 1

for entry in $running; do
    key=${entry#*:}; key=${key%%:*}
    name=${entry##*:}
    jq --arg p "$name" --arg f "$target" \
        '.findings | map({file: $f, perspective: $p} + .)' "$tmp/out.$key" > "$tmp/json.$key" || {
            echo "review.sh: $key returned output that does not match the schema" >&2
            cat "$tmp/out.$key" "$tmp/err.$key" >&2
            exit 1
        }
done

jq -s 'add | sort_by(.line | tostring | capture("(?<n>[0-9]+)").n | tonumber)' "$tmp"/json.*
