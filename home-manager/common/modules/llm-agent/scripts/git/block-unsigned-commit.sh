#!/usr/bin/env bash
set -u

deny() {
  printf 'Blocked: %s creates an unsigned commit. Use `git commit`, or pass -S to `git commit-tree`.\n' "$1" >&2
  exit 2
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in "cd "*) continue ;; esac
  read -ra ARGS <<< "$SEG"
  set -- "${ARGS[@]}"

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
