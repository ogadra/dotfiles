#!/usr/bin/env bash
set -uo pipefail

MAX_LINES=3
REVIEW="$HOME/.claude/skills/readable-writing/scripts/review.sh"

usage() {
  cat >&2 <<'EOF'
usage: pr-body.sh --title <title> --body-file <path> [gh pr create args...]
       pr-body.sh --edit [--title <title>] --body-file <path> [gh pr edit args...]
EOF
  exit 2
}

title=""
body_file=""
edit=0
rest=()
while [ $# -gt 0 ]; do
  case "$1" in
    --title) title=${2-}; shift 2 || usage ;;
    --title=*) title=${1#--title=}; shift ;;
    --body-file) body_file=${2-}; shift 2 || usage ;;
    --body-file=*) body_file=${1#--body-file=}; shift ;;
    --edit) edit=1; shift ;;
    --body|--body=*|-b) echo "pr-body.sh: bodyは --body-file で渡す。" >&2; exit 2 ;;
    *) rest+=("$1"); shift ;;
  esac
done

# gh pr edit keeps the current title when --title is omitted, so only creation requires one
[ -n "$title" ] || [ "$edit" -eq 1 ] || usage
[ -n "$body_file" ] || usage
[ -f "$body_file" ] || { echo "pr-body.sh: no such file: $body_file" >&2; exit 1; }

lines=$(grep -c '[^[:space:]]' "$body_file")
if [ "$lines" -eq 0 ]; then
  echo "pr-body.sh: bodyが空。やったことを${MAX_LINES}行以内で書く。" >&2
  exit 1
fi
if [ "$lines" -gt "$MAX_LINES" ]; then
  cat >&2 <<EOF
pr-body.sh: bodyが${lines}行ある。${MAX_LINES}行以内に収める。
やったことだけを書く。理由、見出し、動作確認、変更ファイルの列挙は書かない。
EOF
  exit 1
fi

repo=$(git rev-parse --show-toplevel) || exit 1
branch=$(git rev-parse --abbrev-ref HEAD) || exit 1
key=$(printf '%s\n%s' "$repo" "$branch" | sha1sum | cut -c1-16)
state="${TMPDIR:-/tmp}/pr_review_pass_$key"
pass=$(cat "$state" 2>/dev/null || echo 0)
pass=$((pass + 1))
printf '%s\n' "$pass" > "$state"

findings=$(mktemp)
trap 'rm -f "$findings"' EXIT

if ! "$REVIEW" "$body_file" > "$findings"; then
  echo "pr-body.sh: readable-writingのレビューが実行できなかった。" >&2
  exit 1
fi

if [ "$pass" -ge 2 ]; then
  blocking=$(jq '[.[] | select(.source == "mechanical")]' "$findings")
  advisory=$(jq '[.[] | select(.source != "mechanical")]' "$findings")
else
  blocking=$(cat "$findings")
  advisory='[]'
fi

if [ "$(printf '%s' "$advisory" | jq 'length')" -gt 0 ]; then
  echo "pr-body.sh: ${pass}パス目なので次の指摘は通す。" >&2
  printf '%s\n' "$advisory" >&2
fi

if [ "$(printf '%s' "$blocking" | jq 'length')" -gt 0 ]; then
  printf '%s\n' "$blocking" >&2
  echo "pr-body.sh: 指摘を直して再実行する。" >&2
  exit 1
fi

rm -f "$state"

if [ "$edit" -eq 1 ]; then
  gh_args=(pr edit)
else
  gh_args=(pr create)
fi
[ -n "$title" ] && gh_args+=(--title "$title")
gh_args+=(--body-file "$body_file")

exec gh "${gh_args[@]}" ${rest[@]+"${rest[@]}"}
