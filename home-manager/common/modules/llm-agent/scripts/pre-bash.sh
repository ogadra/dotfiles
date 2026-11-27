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

# The text only fills an input box and the user decides whether to run it, so the guards skip it
if OUT=$(printf '%s' "$CMD" | "$SCRIPT_DIR/send-text.sh"); then
  PANE=${OUT%%$'\n'*}
  TEXT=${OUT#*$'\n'}
  HAS_SUDO=0
  while IFS= read -r SEG; do
    case "$SEG" in
      cd|"cd "*) deny "cd is not allowed in herdr pane send-text. Pass the directory with an option such as git -C <dir> or an absolute path, or open a tab with herdr tab create --cwd <dir> for a sudo command." ;;
      sudo|"sudo "*) HAS_SUDO=1 ;;
    esac
  done < <(printf '%s' "$TEXT" | NORMALIZE_KEEP_GIT=1 "$SCRIPT_DIR/normalize.sh")
  if [ "$PANE" != "${HERDR_PANE_ID:-}" ]; then
    [ "$HAS_SUDO" = 1 ] || deny "only commands with sudo go to another tab. Send other commands to your own pane (${HERDR_PANE_ID:-herdr pane current}) as '! <command>'."
    exit 0
  fi
  SCREEN=$(herdr pane read "$PANE" --source visible) || deny "could not read pane $PANE to check its input box."
  BOX=$(printf '%s\n' "$SCREEN" | awk '/^───/ { prev = cur; cur = NR } { line[NR] = $0 } END { for (i = prev + 1; i < cur; i++) print line[i] }' | sed -e 's/^❯//' -e 's/^!//' -e 's/\xc2\xa0//g')
  [ -z "${BOX//[[:space:]]/}" ] || deny "the input box of pane $PANE already has text the user typed. Ask the user to send or clear it, then try again."
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
