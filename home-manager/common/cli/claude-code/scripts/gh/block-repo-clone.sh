#!/usr/bin/env bash
# Block `gh repo clone`; clone via `ghq get` to keep repos under a managed root.
# Input: one gh command per stdin line (e.g., "gh repo clone owner/repo").
set -u

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "gh repo clone "*)
      printf 'Blocked: use `ghq get` instead of `gh repo clone`.\n' >&2
      exit 2
      ;;
  esac
done
exit 0
