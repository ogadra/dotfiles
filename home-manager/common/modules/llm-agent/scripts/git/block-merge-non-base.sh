#!/usr/bin/env bash
# Block `git merge` and `git pull` unless they bring in a remote branch that is the base of the current branch's GitHub PR, or the head of an open PR when the current branch has none, or for `git pull` the current branch itself; input is one normalized git command per stdin line.
set -u

deny() {
  printf 'Blocked: %s\n' "$1" >&2
  printf 'Only `git merge <remote>/<branch>` or `git pull <remote> <branch>` is allowed, where <branch> is the base branch of the GitHub PR for the current branch, or the head branch of an open GitHub PR when the current branch has no PR, or `git pull <remote> <current branch>`.\n' >&2
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

# Arguments are branch names on the remote
require_base() {
  # The network call runs last so a local-branch merge is rejected without querying GitHub
  ERR_FILE=$(mktemp) || deny "cannot create a temporary file for the stderr of \`gh pr view\`."
  BASE=$(cd "$RUN_CWD" && gh pr view --json baseRefName --jq .baseRefName 2>"$ERR_FILE")
  VIEW_RC=$?
  VIEW_ERR=$(cat "$ERR_FILE")
  rm -f "$ERR_FILE"
  if [ "$VIEW_RC" -eq 0 ]; then
    [ -n "$BASE" ] || deny "\`gh pr view\` returned no base branch for the current branch."
    for B in "$@"; do
      [ "$B" = "$BASE" ] || deny "\"$B\" is not the PR base branch \"$BASE\"."
    done
    return 0
  fi
  printf '%s\n' "$VIEW_ERR" | grep -q '^no pull requests found for branch "' || deny "cannot look up the GitHub PR for the current branch: $VIEW_ERR"
  for B in "$@"; do
    OPEN=$(cd "$RUN_CWD" && gh pr list --head "$B" --state open --json number --jq length 2>/dev/null) || deny "cannot list open GitHub PRs whose head branch is \"$B\"."
    case "$OPEN" in
      ""|*[!0-9]*) deny "\`gh pr list\` returned \"$OPEN\" instead of a count of open GitHub PRs whose head branch is \"$B\"." ;;
    esac
    [ "$OPEN" -gt 0 ] || deny "the current branch has no GitHub PR, and \"$B\" is not the head branch of an open GitHub PR."
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

  # xargs honors quotes without running anything, so a quoted -m message stays one word
  SPLIT=$(printf '%s' "$SEG" | xargs -n1 2>/dev/null) || deny "cannot split \"$SEG\" into words; balance its quotes."
  WORDS=()
  while IFS= read -r W; do WORDS+=("$W"); done <<< "$SPLIT"
  set -- "${WORDS[@]}"
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
    require_base "${BRANCHES[@]}"
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
  CUR=$(git -C "$RUN_CWD" symbolic-ref --quiet --short HEAD 2>/dev/null)
  if [ -z "$REBASE" ]; then
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
  # Pulling the same-named remote branch only catches up with it, so no PR is needed
  SAME=true
  for B in "${BRANCHES[@]}"; do
    [ "$B" = "$CUR" ] || SAME=false
  done
  [ "$SAME" = true ] && continue
  require_base "${BRANCHES[@]}"
done
exit 0
