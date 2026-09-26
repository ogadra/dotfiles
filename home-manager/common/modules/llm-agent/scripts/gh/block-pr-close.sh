#!/usr/bin/env bash
# Block `gh pr close` so an agent cannot abandon a pull request on its own; input is one gh command per stdin line.
set -u

deny() {
  printf 'Blocked: `gh pr close` is not allowed in agent sessions; ask the user to close the pull request.\n' >&2
  exit 2
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "gh pr close"|"gh pr close "*)
      deny
      ;;
  esac
done
exit 0
