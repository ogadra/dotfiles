#!/usr/bin/env bash
# Block `git add` of everything (-A, --all, -u, --update, .); input is one git command per stdin line.
set -u

ADD_RE='^git[[:space:]]+add([[:space:]]|$)'
FLAG_RE='(^|[[:space:]])(-A|--all|-u|--update)([[:space:])}]|$)'
DOT_RE='(^|[[:space:]])\.([[:space:])}]|$)'

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  if [[ "$SEG" =~ $ADD_RE ]] \
    && { [[ "$SEG" =~ $FLAG_RE ]] || [[ "$SEG" =~ $DOT_RE ]]; }; then
    printf 'Blocked: bulk git add is not allowed; inspect and stage explicit files.\n' >&2
    exit 2
  fi
done
exit 0
