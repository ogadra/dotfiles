#!/usr/bin/env bash
# Block `git commit -a` so files are staged intentionally; input is one git command per stdin line.
set -u

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "git commit -a"|"git commit -a "*)
      printf 'Blocked: git commit -a is not allowed; stage files intentionally.\n' >&2
      exit 2
      ;;
  esac
done
exit 0
