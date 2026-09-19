#!/usr/bin/env bash
# Block PR creation and PR body edits that bypass the pr-create wrapper.
# The wrapper caps the body at three lines and runs it through readable-writing.
# Input: one gh command per stdin line (e.g., "gh pr create --title x").
set -u

WRAPPER="$HOME/.claude/scripts/gh/pr-create.sh"

deny() {
  cat >&2 <<EOF
Blocked: \`$1\` は直接実行できない。
PR bodyは、やったことを3行以内で書く。理由、見出し、箇条書き、動作確認、変更ファイルの列挙は書かない。
bodyを一時ファイルに書いてから次を実行する。
  $WRAPPER --title <title> --body-file <path> [gh pr create の引数]
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

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "gh pr create"|"gh pr create "*)
      deny 'gh pr create'
      ;;
    "gh pr edit "*)
      # shellcheck disable=SC2086
      set -- $SEG
      if has_body_flag "$@"; then
        deny 'gh pr edit --body'
      fi
      ;;
  esac
done
exit 0
