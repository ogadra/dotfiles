#!/usr/bin/env bash
# PreToolUse(Bash) hook that rewrites commands into the rtk proxy to compress their output.
set -u

INPUT=$(cat)

CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""')
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')

# A worktree-isolated session rejects git calls it cannot trace to its worktree, and `rtk git` hides that trace
GIT_RE='(^|[^[:alnum:]_-])git([^[:alnum:]_-]|$)'
if [[ "$CWD" == */.claude/worktrees/* ]] && [[ "$CMD" =~ $GIT_RE ]]; then
  exit 0
fi

printf '%s' "$INPUT" | rtk hook claude
