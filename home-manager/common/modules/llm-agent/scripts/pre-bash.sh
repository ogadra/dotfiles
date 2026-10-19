#!/usr/bin/env bash
# PreToolUse(Bash) hook entry for LLM coding agents.
set -u

INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""')

# Guards that query repository state need to run where the command would run, and a failed cd just leaves them in the hook's directory
if [ -n "$CWD" ]; then
  cd "$CWD" 2>/dev/null || true
fi

SEGMENTS=$(printf '%s' "$CMD" | "$SCRIPT_DIR/normalize.sh")

deny() {
  printf 'Blocked: %s\n' "$1" >&2
  exit 2
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue

  case "$SEG" in
    "find "*"-delete"*)
      deny "find -delete is not allowed in agent sessions."
      ;;
    "xargs rm"|"xargs rm "*)
      deny "xargs rm is not allowed in agent sessions."
      ;;
  esac
done <<< "$SEGMENTS"

# The check list is substituted at build time, so each profile ships a script without a mode switch
for check in @checks@; do
  printf '%s\n' "$SEGMENTS" | "$SCRIPT_DIR/$check"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done

exit 0
