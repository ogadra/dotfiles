#!/usr/bin/env bash
# Block `git merge` and `git pull` unless they bring in the remote base branch of the current PR; input is one normalized git command per stdin line.
set -u

deny() {
  printf 'Blocked: %s\n' "$1" >&2
  printf 'Only `git merge <remote>/<base>` or `git pull <remote> <base>` is allowed, where <base> is the base branch of the GitHub PR for the current branch.\n' >&2
  exit 2
}

# HEAD counts as pushed when any remote-tracking branch contains it, matching block-rewrite-pushed.sh
pushed() {
  REMOTE_BRANCHES=$(git -C "$RUN_CWD" branch -r --contains HEAD 2>/dev/null | grep -v -e ' -> ' | tr -d ' ' | paste -sd, -)
  [ -n "$REMOTE_BRANCHES" ]
}

# Resolve a commit-ish to its branch name on the remote, or deny when it is not a remote-tracking branch
remote_branch() {
  REF=$(git -C "$RUN_CWD" rev-parse --symbolic-full-name "$1" 2>/dev/null)
  case "$REF" in
    refs/remotes/*) ;;
    *) deny "\"$1\" is not a remote-tracking branch; fetch and merge <remote>/<branch> instead." ;;
  esac
  # lstrip=3 drops "refs/remotes/<remote>/" and keeps slashes inside the branch name
  git -C "$RUN_CWD" for-each-ref --format='%(refname:lstrip=3)' "$REF"
}

# $1 is the rebase command suggested when there is no PR and HEAD is not pushed; the rest are branch names on the remote
require_base() {
  SUGGEST=$1
  shift
  # The network call runs last so a local-branch merge is rejected without querying GitHub
  BASE=$(cd "$RUN_CWD" && gh pr view --json baseRefName --jq .baseRefName 2>/dev/null)
  if [ -z "$BASE" ]; then
    printf 'Blocked: the current branch has no GitHub PR, so there is no base branch to merge.\n' >&2
    # A pushed HEAD cannot be rebased under block-rewrite-pushed.sh, so it needs a PR to get a base branch to merge
    if pushed; then
      printf 'HEAD is already pushed (%s). Open a PR for the current branch first, then merge its base branch.\n' "$REMOTE_BRANCHES" >&2
    else
      printf 'HEAD is not pushed yet. Use `%s` instead.\n' "$SUGGEST" >&2
    fi
    exit 2
  fi
  for B in "$@"; do
    [ "$B" = "$BASE" ] || deny "\"$B\" is not the PR base branch \"$BASE\"."
  done
}

# `cd <abs>` lines from check.sh mark where each command runs
RUN_CWD=$PWD
while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "cd "*) RUN_CWD=${SEG#cd }; continue ;;
    "git merge"|"git merge "*|"git pull"|"git pull "*) ;;
    *) continue ;;
  esac

  # xargs honors quotes without running anything, so a quoted -m message stays one word; plain splitting is the fallback for unbalanced quotes
  WORDS=()
  if SPLIT=$(printf '%s' "$SEG" | xargs -n1 2>/dev/null); then
    while IFS= read -r W; do WORDS+=("$W"); done <<< "$SPLIT"
  fi
  if [ "${#WORDS[@]}" -gt 0 ]; then
    set -- "${WORDS[@]}"
  else
    # shellcheck disable=SC2086
    set -- $SEG
  fi
  shift # drop "git"
  SUB=$1
  shift

  if [ "$SUB" = "merge" ]; then
    COMMITS=""
    while [ $# -gt 0 ]; do
      case "$1" in
        # These finish or drop an in-progress merge without bringing in new commits
        --abort|--continue|--quit) continue 2 ;;
        # Options that take their value as the next word
        -m|-F|-s|-X|--file|--strategy|--strategy-option|--into-name)
          shift 2 || break
          ;;
        -*) shift ;;
        *) COMMITS="$COMMITS $1"; shift ;;
      esac
    done
    # With no commit, git merges the upstream of the current branch
    [ -n "$COMMITS" ] || COMMITS=" @{upstream}"

    BRANCHES=()
    for C in $COMMITS; do
      B=$(remote_branch "$C") || exit 2
      BRANCHES+=("$B")
    done
    require_base "git rebase$COMMITS" "${BRANCHES[@]}"
    continue
  fi

  # git pull: the last --rebase/--no-rebase wins, and config decides when neither is given
  REBASE=""
  REPO=""
  REFSPECS=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --rebase=false|--no-rebase) REBASE=false; shift ;;
      -r|--rebase|--rebase=*) REBASE=true; shift ;;
      # Options that take their value as the next word
      -s|-X|-o|-j|--strategy|--strategy-option|--server-option|--jobs|--depth|--deepen|--shallow-since|--shallow-exclude|--upload-pack|--negotiation-tip)
        shift 2 || break
        ;;
      -*) shift ;;
      *)
        if [ -z "$REPO" ]; then REPO=$1; else REFSPECS+=("$1"); fi
        shift
        ;;
    esac
  done
  if [ -z "$REBASE" ]; then
    CUR=$(git -C "$RUN_CWD" symbolic-ref --quiet --short HEAD 2>/dev/null)
    MODE=$(git -C "$RUN_CWD" config --get "branch.$CUR.rebase" 2>/dev/null || git -C "$RUN_CWD" config --get pull.rebase 2>/dev/null)
    case "$MODE" in
      ""|false|no|off|0) REBASE=false ;;
      *) REBASE=true ;;
    esac
  fi

  if [ "$REBASE" = "true" ]; then
    if pushed; then
      printf 'Blocked: `git pull --rebase` rewrites HEAD, which is already pushed (%s).\n' "$REMOTE_BRANCHES" >&2
      printf 'Merge the PR base branch instead with `git pull --no-rebase <remote> <base>`.\n' >&2
      exit 2
    fi
    continue
  fi

  # Only a configured remote counts, so `git pull . <branch>` or a local path cannot merge a local branch
  if [ -n "$REPO" ] && ! git -C "$RUN_CWD" remote | grep -qxF -- "$REPO"; then
    deny "\"$REPO\" is not a configured remote."
  fi
  BRANCHES=()
  if [ "${#REFSPECS[@]}" -eq 0 ]; then
    # Without a refspec, git pulls the upstream of the current branch
    B=$(remote_branch "@{upstream}") || exit 2
    BRANCHES+=("$B")
  else
    for R in "${REFSPECS[@]}"; do
      R=${R#+}
      R=${R%%:*}
      BRANCHES+=("${R#refs/heads/}")
    done
  fi
  require_base "git pull --rebase${REPO:+ $REPO}${REFSPECS[*]:+ ${REFSPECS[*]}}" "${BRANCHES[@]}"
done
exit 0
