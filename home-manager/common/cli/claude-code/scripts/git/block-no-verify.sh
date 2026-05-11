#!/usr/bin/env bash
# Block git invocations that bypass hooks:
#   - any `git ... --no-verify`
#   - `git commit -n` (including bundled short flags like `-nam`)
# Input: one git command per stdin line.
set -u

deny() {
  printf 'Blocked: %s bypasses hooks. Fix the underlying hook failure instead.\n' "$1" >&2
  exit 2
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  # shellcheck disable=SC2086
  set -- $SEG

  IS_COMMIT=0
  case "$SEG" in
    "git commit"|"git commit "*) IS_COMMIT=1 ;;
  esac

  for arg in "$@"; do
    case "$arg" in
      --no-verify|--no-verify=*) deny '`--no-verify`' ;;
    esac
    if [ "$IS_COMMIT" -eq 1 ]; then
      case "$arg" in
        --*) ;;
        -*n*) deny '`git commit -n`' ;;
      esac
    fi
  done
done
exit 0
