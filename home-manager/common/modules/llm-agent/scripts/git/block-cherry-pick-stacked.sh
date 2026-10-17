#!/usr/bin/env bash
# Block `git cherry-pick` on a stacked branch, whose GitHub PR targets a branch other than the default branch; input is one normalized git command per stdin line.
set -u

deny() {
  printf 'Blocked: %s\n' "$1" >&2
  printf 'Cherry-picked commits get new hashes, so every later change to the source branch has to be picked again by hand and the child branch history fills with duplicates.\n' >&2
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

  # shellcheck disable=SC2086
  for W in $SEG; do
    case "$W" in
      # These finish or drop an in-progress cherry-pick without picking new commits
      --abort|--continue|--quit|--skip) continue 2 ;;
    esac
  done

  # A branch without a PR has no base yet, so it is not stacked; any other gh failure leaves the base unknown
  if ! BASE=$(cd "$RUN_CWD" && gh pr view --json baseRefName --jq .baseRefName 2>&1); then
    case "$BASE" in
      "no pull requests found"*) continue ;;
      *) deny "cannot look up the PR base branch: $BASE" ;;
    esac
  fi
  DEFAULT=$(cd "$RUN_CWD" && gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>&1) \
    || deny "cannot look up the default branch: $DEFAULT"
  [ "$BASE" = "$DEFAULT" ] || deny "the PR for the current branch is stacked on \"$BASE\", not the default branch \"$DEFAULT\"."
done
exit 0
