#!/usr/bin/env bash
# Block rewriting commits that are already pushed; input is one normalized git command per stdin line.
set -u

BRANCHES=""

# HEAD counts as pushed when any remote-tracking branch contains it.
pushed() {
  REMOTE=$(git branch -r --contains HEAD 2>/dev/null) || return 1
  BRANCHES=$(printf '%s\n' "$REMOTE" | grep -v -e ' -> ' | tr -d ' ' | paste -sd, -)
  [ -n "$BRANCHES" ]
}

deny() {
  printf 'Blocked: HEAD is already pushed (%s). Pushed history is a permanent record here, mistakes included.\n' "$BRANCHES" >&2
  printf 'Do not rewrite it with `%s`, and do not look for another route to the same result. Add a follow-up commit.\n' "$1" >&2
  printf 'Merges never squash, so the follow-up commit is meant to stay visible. That is the intended outcome, not a mess to clean up.\n' >&2
  exit 2
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "git"|"git "*) ;;
    *) continue ;;
  esac

  # shellcheck disable=SC2086
  set -- $SEG
  shift

  # Skip options that sit before the subcommand, such as `git -C <dir> commit --amend`.
  while [ $# -gt 0 ]; do
    case "$1" in
      -c|-C|--git-dir|--work-tree|--namespace|--exec-path)
        shift 2 || break
        ;;
      -*)
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  [ $# -gt 0 ] || continue
  SUB="$1"
  shift

  case "$SUB" in
    commit)
      IS_AMEND=0
      for arg in "$@"; do
        case "$arg" in
          --am*) IS_AMEND=1 ;;
        esac
      done
      [ "$IS_AMEND" -eq 1 ] || continue
      pushed && deny "git commit --amend"
      ;;
    rebase)
      # --abort and --quit end an in-progress rebase without rewriting anything.
      for arg in "$@"; do
        case "$arg" in
          --abort|--quit) continue 2 ;;
        esac
      done
      pushed && deny "git rebase"
      ;;
  esac
done
exit 0
