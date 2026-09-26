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

for child in block-repo-clone.sh block-pr-body.sh block-pr-close.sh; do
  printf '%s' "$GH_SEGMENTS" | "$SCRIPT_DIR/$child"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done
exit 0
