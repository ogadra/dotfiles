#!/usr/bin/env bash
# Block `git clone` so `ghq get` keeps repos under a managed root; input is one git command per stdin line.
set -u

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "git clone "*)
      printf 'Blocked: use `ghq get` instead of `git clone`.\n' >&2
      exit 2
      ;;
  esac
done
exit 0
