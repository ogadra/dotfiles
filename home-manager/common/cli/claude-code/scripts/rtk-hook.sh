#!/usr/bin/env bash
# PreToolUse(Bash) hook that rewrites commands into the rtk proxy to compress their output.
set -u

INPUT=$(cat)

CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""')
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')

# Claude Code reads the command after this hook rewrote it, and a worktree-isolated session
# refuses any git call it cannot trace to its own worktree; `rtk git ...` hides that trace, so
# leave every command naming git alone once the session sits under .claude/worktrees/
GIT_RE='(^|[^[:alnum:]_-])git([^[:alnum:]_-]|$)'
if [[ "$CWD" == */.claude/worktrees/* ]] && [[ "$CMD" =~ $GIT_RE ]]; then
  exit 0
fi

printf '%s' "$INPUT" | rtk hook claude
