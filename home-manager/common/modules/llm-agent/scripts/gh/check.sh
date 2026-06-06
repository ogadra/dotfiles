#!/usr/bin/env bash
# Dispatch gh-related Bash commands to per-check scripts.
set -u

INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')

GH_SEGMENTS=""
while IFS= read -r SEG; do
  SEG="${SEG#"${SEG%%[![:space:]]*}"}"
  case "$SEG" in
    "gh"|"gh "*) GH_SEGMENTS="${GH_SEGMENTS}${SEG}"$'\n' ;;
  esac
done < <(printf '%s\n' "$CMD" | tr ';&|' '\n')

[ -z "$GH_SEGMENTS" ] && exit 0

for child in block-repo-clone.sh; do
  printf '%s' "$GH_SEGMENTS" | "$SCRIPT_DIR/$child"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done
exit 0
