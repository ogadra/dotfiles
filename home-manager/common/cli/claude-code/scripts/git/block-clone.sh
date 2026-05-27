#!/usr/bin/env bash
# Block `git clone`; clone via `ghq get` to keep repos under a managed root.
# Input: one git command per stdin line (e.g., "git clone https://...").
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
