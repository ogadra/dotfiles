#!/usr/bin/env bash
# Block PR creation and body edits that bypass the pr-body wrapper, which caps the body at three lines and runs readable-writing; input is one gh command per stdin line.
set -u

# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"

WRAPPER="$HOME/.claude/scripts/gh/pr-body.sh"
PULLS_RE="(^|[[:space:]\"'])/?repos/[^/[:space:]]+/[^/[:space:]]+/pulls([?\"'[:space:]]|$)"
PULL_RE="(^|[[:space:]\"'])/?repos/[^/[:space:]]+/[^/[:space:]]+/pulls/[0-9]+([?\"'[:space:]]|$)"

deny() {
  cat >&2 <<EOF
Blocked: \`$1\` は直接実行できない。
PR bodyは、やったことを3行以内で書く。理由、見出し、動作確認、変更ファイルの列挙は書かない。
bodyを一時ファイルに書いてから次を実行する。
  $2
EOF
  exit 2
}

has_body_flag() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      --body|--body=*|-b|--body-file|--body-file=*|-F) return 0 ;;
    esac
  done
  return 1
}

has_api_body() {
  local arg
  while [ $# -gt 0 ]; do
    case "$1" in
      -f|-F|--field|--raw-field)
        arg=$(printf '%s' "${2:-}" | tr -d "\"'")
        case "$arg" in body=*) return 0 ;; esac
        shift
        ;;
      -f*|-F*|--field=*|--raw-field=*)
        arg=$(printf '%s' "${1#--*=}" | tr -d "\"'")
        arg=${arg#-[fF]}
        case "$arg" in body=*) return 0 ;; esac
        ;;
      --input|--input=*) return 0 ;;
    esac
    shift
  done
  return 1
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "gh pr create"|"gh pr create "*)
      deny 'gh pr create' "$WRAPPER --title <title> --body-file <path> [gh pr create の引数]"
      ;;
    "gh pr edit "*)
      # shellcheck disable=SC2086
      set -- $SEG
      if has_body_flag "$@"; then
        deny 'gh pr edit --body' "$WRAPPER --edit --body-file <path> [gh pr edit の引数]"
      fi
      ;;
    "gh api "*)
      # shellcheck disable=SC2086
      set -- $SEG
      has_api_body "$@" || continue
      METHOD=$(rest_method "$SEG")
      if [ "$METHOD" = "POST" ] && printf '%s\n' "$SEG" | grep -Eq "$PULLS_RE"; then
        deny 'gh api POST /repos/<owner>/<repo>/pulls' "$WRAPPER --title <title> --body-file <path> [gh pr create の引数]"
      fi
      if [ "$METHOD" = "PATCH" ] && printf '%s\n' "$SEG" | grep -Eq "$PULL_RE"; then
        deny 'gh api PATCH /repos/<owner>/<repo>/pulls/<number>' "$WRAPPER --edit --body-file <path> [gh pr edit の引数]"
      fi
      ;;
  esac
done
exit 0
