#!/usr/bin/env bash
# Dispatch git commands to per-check scripts; input is one normalized command per stdin line. `cd` segments become absolute-path lines so children can tell which worktree each git command runs in.
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RUN_CWD=$PWD
GIT_SEGMENTS=""
while IFS= read -r SEG; do
  case "$SEG" in
    "git"|"git "*)
      GIT_SEGMENTS="${GIT_SEGMENTS}${SEG}"$'\n'
      ;;
    "cd"|"cd "*)
      DIR=${SEG#cd}
      DIR=${DIR# }
      [ -z "$DIR" ] && DIR=$HOME
      # Normalization keeps quote characters, so strip a wrapping pair before resolving
      case "$DIR" in
        \"*\") DIR=${DIR#\"}; DIR=${DIR%\"} ;;
        \'*\') DIR=${DIR#\'}; DIR=${DIR%\'} ;;
      esac
      # `git -C ""` normalizes to `cd ""`, and an empty -C is a no-op
      [ -z "$DIR" ] && DIR=.
      case "$DIR" in "~"|"~/"*) DIR=$HOME${DIR#~} ;; esac
      # `cd -` needs OLDPWD, which a normalized command stream cannot reconstruct
      [ "$DIR" = "-" ] && continue
      # An unresolvable cd leaves the tracked cwd alone, matching a `;` chain where git still runs there
      NEXT=$(cd "$RUN_CWD" 2>/dev/null && cd "$DIR" 2>/dev/null && pwd) || continue
      RUN_CWD=$NEXT
      GIT_SEGMENTS="${GIT_SEGMENTS}cd $RUN_CWD"$'\n'
      ;;
  esac
done

[ -z "$GIT_SEGMENTS" ] && exit 0

for child in block-default-commit.sh block-default-push.sh block-force-push.sh block-no-verify.sh block-rewrite-pushed.sh block-clone.sh; do
  printf '%s' "$GIT_SEGMENTS" | "$SCRIPT_DIR/$child"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done
exit 0
