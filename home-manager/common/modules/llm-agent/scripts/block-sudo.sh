#!/usr/bin/env bash
# Block sudo; input is one normalized command per stdin line.
set -u

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    sudo|"sudo "*)
      printf 'Blocked: sudo is not allowed in agent sessions.\n' >&2
      exit 2
      ;;
  esac
done
exit 0
