#!/usr/bin/env bash
# Dispatch git commands to per-check scripts; input is one normalized command per stdin line.
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

GIT_SEGMENTS=""
while IFS= read -r SEG; do
  case "$SEG" in
    "git"|"git "*) GIT_SEGMENTS="${GIT_SEGMENTS}${SEG}"$'\n' ;;
  esac
done

[ -z "$GIT_SEGMENTS" ] && exit 0

for child in block-default-push.sh block-force-push.sh block-no-verify.sh block-amend-pushed.sh block-clone.sh; do
  printf '%s' "$GIT_SEGMENTS" | "$SCRIPT_DIR/$child"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done
exit 0
