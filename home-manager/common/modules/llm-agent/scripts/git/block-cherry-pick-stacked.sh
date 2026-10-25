#!/usr/bin/env bash
# Block `git cherry-pick` of a commit that an upstream branch of a stacked PR already holds; input is one normalized git command per stdin line.
set -u

deny() {
  printf 'Blocked: %s\n' "$1" >&2
  printf 'Cherry-picked commits get new hashes, so every later change to the upstream branch has to be picked again by hand and the child branch history fills with duplicates.\n' >&2
  printf 'Bring in the parent branch with `git merge <remote>/<base>` instead; see the cascade-merge skill for propagating changes through stacked PRs.\n' >&2
  exit 2
}

# `cd <abs>` lines from check.sh mark where each command runs
RUN_CWD=$PWD
while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "cd "*) RUN_CWD=${SEG#cd }; continue ;;
    "git cherry-pick"|"git cherry-pick "*) ;;
    *) continue ;;
  esac

  # xargs honors quotes without running anything, so a quoted value stays one word
  SPLIT=$(printf '%s' "$SEG" | xargs -n1 2>/dev/null) || deny "cannot split \"$SEG\" into words; balance its quotes."
  WORDS=()
  while IFS= read -r W; do WORDS+=("$W"); done <<< "$SPLIT"
  set -- "${WORDS[@]}"
  shift 2 # drop "git cherry-pick"

  REVS=()
  RANGE=false
  while [ $# -gt 0 ]; do
    case "$1" in
      # These finish or drop an in-progress cherry-pick without picking new commits
      --abort|--continue|--quit|--skip) continue 2 ;;
      # Options that take their value as the next word
      -m|-X|--mainline|--strategy|--strategy-option|--cleanup)
        shift 2 || break
        ;;
      -*) shift ;;
      *)
        case "$1" in *..*|^*) RANGE=true ;; esac
        REVS+=("$1")
        shift
        ;;
    esac
  done
  [ "${#REVS[@]}" -gt 0 ] || continue

  # A branch without a PR has no base yet, so it is not stacked; any other gh failure leaves the base unknown
  if ! BASE=$(cd "$RUN_CWD" && gh pr view --json baseRefName --jq .baseRefName 2>&1); then
    case "$BASE" in
      "no pull requests found"*) continue ;;
      *) deny "cannot look up the PR base branch: $BASE" ;;
    esac
  fi
  DEFAULT=$(cd "$RUN_CWD" && gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>&1) \
    || deny "cannot look up the default branch: $DEFAULT"
  [ "$BASE" = "$DEFAULT" ] && continue

  # Follow open PRs from the base toward the default branch; a parent without an open PR ends the stack, and the default branch is upstream of every stack
  UPSTREAM=("$DEFAULT")
  B=$BASE
  while [ -n "$B" ] && [ "$B" != "$DEFAULT" ]; do
    for U in "${UPSTREAM[@]}"; do
      [ "$U" = "$B" ] && deny "the PR chain loops back to \"$B\"."
    done
    UPSTREAM+=("$B")
    PARENT=$B
    B=$(cd "$RUN_CWD" && gh pr list --head "$PARENT" --state open --json baseRefName --jq '.[0].baseRefName // ""' 2>&1) \
      || deny "cannot look up the PR base of \"$PARENT\": $B"
  done

  # git cherry-pick picks a lone commit by itself but walks any range
  if [ "$RANGE" = true ]; then
    COMMITS=$(git -C "$RUN_CWD" rev-list "${REVS[@]}" 2>&1) || deny "cannot resolve \"${REVS[*]}\": $COMMITS"
  else
    COMMITS=""
    for R in "${REVS[@]}"; do
      C=$(git -C "$RUN_CWD" rev-parse --verify --quiet "$R^{commit}") || deny "cannot resolve \"$R\" to a commit."
      COMMITS="$COMMITS$C"$'\n'
    done
  fi

  while IFS= read -r C; do
    [ -n "$C" ] || continue
    # Local and remote-tracking branches both count, since an unpushed parent commit causes the same duplication
    HOLDERS=$(
      git -C "$RUN_CWD" for-each-ref --contains "$C" --format='%(refname:lstrip=2)' refs/heads
      git -C "$RUN_CWD" for-each-ref --contains "$C" --format='%(refname:lstrip=3)' refs/remotes
    )
    for U in "${UPSTREAM[@]}"; do
      if printf '%s\n' "$HOLDERS" | grep -qxF -- "$U"; then
        deny "commit ${C:0:12} is already on \"$U\", an upstream branch of this stacked PR based on \"$BASE\"."
      fi
    done
  done <<< "$COMMITS"
done
exit 0
