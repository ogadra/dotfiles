#!/usr/bin/env bash
# Block `git worktree add|move` unless the target is a direct child of <main repo>/.claude/worktrees; input is one git command per stdin line.
set -u

# Collapse . and .. without touching the filesystem, since macOS realpath lacks -m and the target usually does not exist yet
normalize_path() {
  local part out=""
  local IFS=/
  for part in $1; do
    case "$part" in
      ""|.) ;;
      ..) out=${out%/*} ;;
      *) out="$out/$part" ;;
    esac
  done
  printf '%s' "${out:-/}"
}

# `cd <abs>` lines from check.sh mark where each command runs
RUN_CWD=$PWD
while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "cd "*) RUN_CWD=${SEG#cd }; continue ;;
    "git worktree add "*) WANT=1 ;;
    "git worktree move "*) WANT=2 ;;
    *) continue ;;
  esac

  # shellcheck disable=SC2086
  set -- ${SEG#git worktree * }
  TARGET=""
  N=0
  while [ $# -gt 0 ]; do
    case "$1" in
      -b|-B|--reason) shift 2 || break; continue ;;
      -*) shift; continue ;;
    esac
    N=$((N + 1))
    if [ "$N" -eq "$WANT" ]; then
      TARGET=$1
      break
    fi
    shift
  done
  [ -n "$TARGET" ] || continue

  # Strip one wrapping quote pair
  case "$TARGET" in
    \"*\") TARGET=${TARGET#\"}; TARGET=${TARGET%\"} ;;
    \'*\') TARGET=${TARGET#\'}; TARGET=${TARGET%\'} ;;
  esac
  case "$TARGET" in "~"|"~/"*) TARGET=$HOME${TARGET#~} ;; esac

  # The common dir points at the main repository even from inside a linked worktree, so nested worktrees land beside their siblings
  COMMON=$(git -C "$RUN_CWD" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || continue
  ROOT=$(cd "$COMMON/.." 2>/dev/null && pwd -P) || continue
  BASE=$(cd "$RUN_CWD" 2>/dev/null && pwd -P) || continue

  case "$TARGET" in
    /*) ABS=$TARGET ;;
    *) ABS=$BASE/$TARGET ;;
  esac
  ABS=$(normalize_path "$ABS")
  # Resolve the existing parent so a symlinked prefix such as /var -> /private/var compares equal to ROOT
  PARENT=$(cd "${ABS%/*}" 2>/dev/null && pwd -P) || PARENT=${ABS%/*}

  ALLOWED="$ROOT/.claude/worktrees"
  if [ "$PARENT" != "$ALLOWED" ]; then
    printf 'Blocked: worktrees must be direct children of %s/.\n' "$ALLOWED" >&2
    exit 2
  fi
done
exit 0
