#!/usr/bin/env bash
# PreToolUse(Bash) hook entry: dispatch to per-category check scripts.
set -u

INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for check in git/check.sh; do
  printf '%s' "$INPUT" | "$SCRIPT_DIR/$check"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done
exit 0
