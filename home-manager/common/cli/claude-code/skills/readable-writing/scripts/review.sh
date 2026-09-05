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
prompts="$skill_dir/prompts"

run_id="$(date -u +%Y%m%d-%H%M%S)-$$"
now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
log_dir="${XDG_STATE_HOME:-${HOME:-/tmp}/.local/state}/readable-writing"
log="$log_dir/findings.tsv"

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
    | jq --arg f "$target" 'map({file: $f, source: "mechanical"} + .)' > "$tmp/json.mechanical"

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

        cat "$prompts/judgement.md"
        printf '\n'
        cat "$prompts/fields.md"
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
        '.findings | map({file: $f, source: "llm", perspective: $p} + .)' "$tmp/out.$key" > "$tmp/json.$key" || {
            echo "review.sh: $key returned output that does not match the schema" >&2
            cat "$tmp/out.$key" "$tmp/err.$key" >&2
            exit 1
        }
done

# 列を増やすときは末尾に足す。
log_findings() {
    mkdir -p "$log_dir" || return 1
    jq -r --arg time "$now" --arg run "$run_id" --arg target "$target" --arg lang "$lang_dirs" '
        .[] | [$time, $run, $target, $lang,
               .source, .perspective, .category,
               (.line | tostring), .quote, .problem] | @tsv' \
        "$tmp/merged.json" > "$tmp/records.tsv" || return 1
    # jqから直接追記すると4KiBごとに書き込みが割れて、並行する実行と混ざる。
    cat "$tmp/records.tsv" >> "$log"
}

jq -s 'add | sort_by(.line | tostring | capture("(?<n>[0-9]+)").n | tonumber)' \
    "$tmp"/json.* > "$tmp/merged.json"

cat "$tmp/merged.json"

log_findings || echo "review.sh: failed to write $log" >&2
