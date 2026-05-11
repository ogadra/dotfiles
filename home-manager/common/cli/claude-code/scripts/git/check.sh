#!/usr/bin/env bash
# Dispatch git-related Bash commands to per-check scripts.
set -u

INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""')
[ -n "$CWD" ] && cd "$CWD" 2>/dev/null

GIT_SEGMENTS=""
while IFS= read -r SEG; do
  SEG="${SEG#"${SEG%%[![:space:]]*}"}"
  case "$SEG" in
    "git"|"git "*) GIT_SEGMENTS="${GIT_SEGMENTS}${SEG}"$'\n' ;;
  esac
done < <(printf '%s\n' "$CMD" | tr ';&|' '\n')

[ -z "$GIT_SEGMENTS" ] && exit 0

for child in block-default-push.sh block-no-verify.sh; do
  printf '%s' "$GIT_SEGMENTS" | "$SCRIPT_DIR/$child"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done
exit 0
