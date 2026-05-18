---
name: cascade-merge
description: Cascade merge changes through a chain of dependent branches. Use when updating stacked/chained PRs, propagating changes from a parent branch to all downstream branches, or when the user mentions "cascade merge", "propagate changes", "update dependent branches", or "merge to downstream branches".
allowed-tools: Bash(gh pr list:*), Bash(jq:*), Bash(git checkout:*), Bash(git switch:*), Bash(git merge:*), Bash(git push origin:*), Bash(git status:*), Bash(git branch:*), Bash(git fetch:*)
---

# Cascade Merge

Propagate changes from a source branch through all dependent branches in a PR chain.

## Workflow

### 1. Identify Downstream Branches

```bash
gh pr list --state open --json number,title,headRefName,baseRefName --limit 50 | jq -r '.[] | "\(.baseRefName)\t\(.headRefName)"'
```

Build the dependency chain by finding PRs where `baseRefName` matches the current branch, then recursively find PRs based on those branches.

### 2. Merge and Push Each Branch

For each downstream branch in order:

```bash
git checkout <downstream-branch>
git merge <upstream-branch> --no-edit
git push origin <downstream-branch>
```

### 3. Handle Conflicts

If a merge conflict occurs:
1. Report the conflict to the user
2. Ask how to proceed (resolve manually, skip branch, or abort)

## Example

Given this PR chain:
```
main
 └── feature-1
      └── feature-2
           └── feature-3
```

When `feature-1` is updated, cascade merge will:
1. Merge `feature-1` into `feature-2`, push
2. Merge `feature-2` into `feature-3`, push

## Output

Report results as a table:

| Branch | Merged From | Status |
|--------|-------------|--------|
| feature-2 | feature-1 | Done |
| feature-3 | feature-2 | Done |
