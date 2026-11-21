#!/usr/bin/env bash
# Block `git commit-tree` without -S and any `--no-gpg-sign`, since commit-tree ignores commit.gpgsign and the pre-push hook only catches the result after the work is done; input is one git command per stdin line.
set -u

deny() {
  printf 'Blocked: %s creates an unsigned commit. Use `git commit`, or pass -S to `git commit-tree`.\n' "$1" >&2
  exit 2
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  # `cd` context lines carry no flags
  case "$SEG" in "cd "*) continue ;; esac
  # shellcheck disable=SC2086
  set -- $SEG

  for arg in "$@"; do
    case "$arg" in
      --no-gpg-sign) deny '`--no-gpg-sign`' ;;
    esac
  done

  case "$SEG" in
    "git commit-tree"|"git commit-tree "*) ;;
    *) continue ;;
  esac
  SIGNED=0
  for arg in "$@"; do
    case "$arg" in
      -S*|--gpg-sign|--gpg-sign=*) SIGNED=1 ;;
    esac
  done
  [ "$SIGNED" -eq 1 ] || deny '`git commit-tree` without -S'
done
exit 0
