#!/usr/bin/env bash
# Dispatch gh commands to per-check scripts; input is one normalized command per stdin line.
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

GH_SEGMENTS=""
while IFS= read -r SEG; do
  case "$SEG" in
    "gh"|"gh "*) GH_SEGMENTS="${GH_SEGMENTS}${SEG}"$'\n' ;;
  esac
done

[ -z "$GH_SEGMENTS" ] && exit 0

case "$ISUCON" in
  0) readonly children="block-repo-clone.sh block-pr-body.sh block-pr-close.sh" ;;
  1) readonly children="block-repo-clone.sh block-pr-close.sh" ;;
  *) printf 'Blocked: ISUCON must be 0 or 1.\n' >&2; exit 2 ;;
esac
for child in $children; do
  printf '%s' "$GH_SEGMENTS" | "$SCRIPT_DIR/$child"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done
exit 0
