#!/usr/bin/env bash
# Block any git invocation that uses `--no-verify`.
# Input: one git command per stdin line.
set -u

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  # shellcheck disable=SC2086
  set -- $SEG
  for arg in "$@"; do
    case "$arg" in
      --no-verify|--no-verify=*)
        printf 'Blocked: `--no-verify` is not allowed. Fix the underlying hook failure instead.\n' >&2
        exit 2
        ;;
    esac
  done
done
exit 0
