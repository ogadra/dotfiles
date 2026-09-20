#!/usr/bin/env bash
set -u

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "git commit"|"git commit "*) ;;
    *) continue ;;
  esac

  # shellcheck disable=SC2086
  set -- $SEG
  IS_AMEND=0
  for arg in "$@"; do
    case "$arg" in
      --am*) IS_AMEND=1 ;;
    esac
  done
  [ "$IS_AMEND" -eq 1 ] || continue

  BRANCHES=$(git branch -r --contains HEAD 2>/dev/null) || continue
  BRANCHES=$(printf '%s\n' "$BRANCHES" | grep -v -e ' -> ' | tr -d ' ' | paste -sd, -)
  [ -n "$BRANCHES" ] || continue

  printf 'Blocked: HEAD is already pushed (%s), so amending it would need a force push. Add a new commit instead.\n' "$BRANCHES" >&2
  exit 2
done
exit 0
