#!/usr/bin/env bash
# Dispatch git commands to per-check scripts; input is one normalized command per stdin line. `cd` segments are forwarded as absolute paths.
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
      # Strip one wrapping quote pair
      case "$DIR" in
        \"*\") DIR=${DIR#\"}; DIR=${DIR%\"} ;;
        \'*\') DIR=${DIR#\'}; DIR=${DIR%\'} ;;
      esac
      # An empty -C is a no-op
      [ -z "$DIR" ] && DIR=.
      case "$DIR" in "~"|"~/"*) DIR=$HOME${DIR#~} ;; esac
      # `cd -` needs OLDPWD, which is untracked
      [ "$DIR" = "-" ] && continue
      # A failed cd keeps the old cwd, matching a `;` chain
      NEXT=$(cd "$RUN_CWD" 2>/dev/null && cd "$DIR" 2>/dev/null && pwd) || continue
      RUN_CWD=$NEXT
      GIT_SEGMENTS="${GIT_SEGMENTS}cd $RUN_CWD"$'\n'
      ;;
  esac
done

[ -z "$GIT_SEGMENTS" ] && exit 0

children="block-default-commit.sh block-default-push.sh block-force-push.sh block-no-verify.sh block-rewrite-pushed.sh block-merge-non-base.sh block-cherry-pick-stacked.sh block-clone.sh block-worktree-outside.sh"
if [ "${ISUCON:-0}" = 1 ]; then
  children="block-default-commit.sh block-default-push.sh block-force-push.sh block-rewrite-pushed.sh block-clone.sh block-worktree-outside.sh"
fi
for child in $children; do
  printf '%s' "$GIT_SEGMENTS" | "$SCRIPT_DIR/$child"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done
exit 0
