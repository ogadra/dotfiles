#!/usr/bin/env bash
# Block `gh repo clone` and `gh repo create --clone`; clone via `ghq get` to keep repos under a managed root.
# Input: one gh command per stdin line (e.g., "gh repo clone owner/repo").
set -u

deny() {
  printf 'Blocked: use `ghq get` instead of `%s`.\n' "$1" >&2
  exit 2
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "gh repo clone "*)
      deny 'gh repo clone'
      ;;
    "gh repo create "*)
      # shellcheck disable=SC2086
      set -- $SEG
      for arg in "$@"; do
        case "$arg" in
          --clone|--clone=true|--clone=TRUE|--clone=1)
            deny 'gh repo create --clone'
            ;;
        esac
      done
      ;;
  esac
done
exit 0
