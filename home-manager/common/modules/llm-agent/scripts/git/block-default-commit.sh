#!/usr/bin/env bash
# Block `git commit` on the default branch; input is one git command per stdin line.
set -u

# `cd <abs>` lines from check.sh mark where each command runs
RUN_CWD=$PWD
while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "cd "*) RUN_CWD=${SEG#cd }; continue ;;
    "git commit"|"git commit "*) ;;
    *) continue ;;
  esac

  BRANCH=$(git -C "$RUN_CWD" symbolic-ref --quiet --short HEAD 2>/dev/null) || continue

  # main and master stay unconditional so a local repo without any remote is still covered.
  DEFAULTS="main master $(git -C "$RUN_CWD" config --get init.defaultBranch 2>/dev/null)"
  ORIGIN_HEAD=$(git -C "$RUN_CWD" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  DEFAULTS="$DEFAULTS ${ORIGIN_HEAD#origin/}"

  for D in $DEFAULTS; do
    if [ "$BRANCH" = "$D" ]; then
      # Name the repository because RUN_CWD can differ from the session cwd after `cd` or `git -C`
      REPO=$(git -C "$RUN_CWD" rev-parse --show-toplevel 2>/dev/null) || REPO=$RUN_CWD
      printf 'Blocked: %s is on default branch "%s". Cut a branch first.\n' "$REPO" "$BRANCH" >&2
      exit 2
    fi
  done
done
exit 0
