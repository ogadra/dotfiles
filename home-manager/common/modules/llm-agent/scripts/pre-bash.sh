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

deny() {
  printf 'Blocked: %s\n' "$1" >&2
  exit 2
}

# The text only fills an input box and the user decides whether to run it, so the guards skip it; cd is denied so the directory comes from the pane itself
if TEXT=$(printf '%s' "$CMD" | "$SCRIPT_DIR/send-text.sh"); then
  while IFS= read -r SEG; do
    case "$SEG" in
      cd|"cd "*) deny "cd is not allowed in herdr pane send-text. Open a tab with herdr tab create --cwd <dir> and send the command there." ;;
    esac
  done < <(printf '%s' "$TEXT" | "$SCRIPT_DIR/normalize.sh")
  exit 0
fi

SEGMENTS=$(printf '%s' "$CMD" | "$SCRIPT_DIR/normalize.sh")

# normalize.sh splits quoted multi-line arguments apart, so guards that read such an argument need the command as written
export AGENT_RAW_COMMAND="$CMD"

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

# Run whichever guards the profile deployed; nullglob drops an unmatched glob
shopt -s nullglob
for check in "$SCRIPT_DIR"/block-*.sh "$SCRIPT_DIR/git/check.sh" "$SCRIPT_DIR/gh/check.sh"; do
  printf '%s\n' "$SEGMENTS" | "$check"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done

exit 0
