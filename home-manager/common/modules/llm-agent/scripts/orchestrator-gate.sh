#!/usr/bin/env bash
# Keep a session that loaded the orchestrator skill at its prompt by denying every tool call that does work instead of delegating it to a herdr tab.
set -u

# claude -p sets CLAUDE_CODE_SESSION_ATTENDED=0 even when its parent exported 1, so print-mode runs never reach the gate
[ "${HERDR_ENV:-}" = 1 ] && [ "${CLAUDE_CODE_SESSION_ATTENDED:-}" = 1 ] || exit 0

INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EVENT=$(printf '%s' "$INPUT" | jq -r '.hook_event_name // ""')
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""')
[ -n "$SESSION_ID" ] || exit 0

flag_dir="${XDG_RUNTIME_DIR:-/tmp}/claude-orchestrator"
flag="$flag_dir/${SESSION_ID//[^[:alnum:]-]/_}"

deny() {
  # shellcheck disable=SC2016
  printf 'Blocked: this session runs the orchestrator skill, so %s Delegate the work to an idle herdr lane, or open a temporary one with `herdr tab create` + `herdr agent start` and close it with `herdr tab close` when it finishes.\n' "$1" >&2
  exit 2
}

case "$EVENT" in
  # A typed /orchestrator loads the skill without a Skill tool call, so the prompt is the only trace of it
  UserPromptSubmit)
    if printf '%s' "$INPUT" | jq -e '.prompt // "" | test("^\\s*/orchestrator(\\s|$)")' >/dev/null; then
      mkdir -p "$flag_dir" && touch "$flag"
    fi
    exit 0
    ;;
  SessionEnd)
    rm -f "$flag"
    exit 0
    ;;
  PreToolUse) ;;
  *) exit 0 ;;
esac

TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')

if [ "$TOOL" = Skill ]; then
  if printf '%s' "$INPUT" | jq -e '.tool_input.skill // "" | test("^orchestrator$")' >/dev/null; then
    mkdir -p "$flag_dir" && touch "$flag"
  fi
  exit 0
fi

[ -f "$flag" ] || exit 0

case "$TOOL" in
  Bash)
    CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')
    while IFS= read -r SEG; do
      [ -n "$SEG" ] || continue
      # Instructions travel by SendMessage or as a file path in `herdr agent start` arguments, so no herdr command needs a substitution and any substitution could run work inline
      # shellcheck disable=SC2016
      case "$SEG" in
        *'$('* | *'`'*) deny "command substitution is not allowed." ;;
      esac
      case "$SEG" in
        # A prompt is typed into the worker's input box and mixes with the user's typing there, so messages go through SendMessage instead
        "herdr agent prompt"*) deny "herdr agent prompt is not allowed. Send instructions, rulings and notices to the worker's session with SendMessage." ;;
      esac
      case "$SEG" in
        # The parent reads issues to plan lanes and checks worker reports with git and gh; jq reads herdr's JSON output; normalize.sh turns `git -C <path>` into a cd line
        "herdr "* | "jq "* | "test "* | "cd "* | "git status"* | "git log"* | "gh pr list"* | "gh issue view"*) ;;
        *) deny "only herdr commands, gh issue view and the git/gh checks of worker reports run here." ;;
      esac
    done < <(printf '%s' "$CMD" | "$SCRIPT_DIR/normalize.sh")
    ;;
  # Instruction files live in a temporary directory, which keeps Write from editing the repository itself
  Write)
    FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""')
    case "$FILE_PATH" in
      /tmp/*) ;;
      *) deny "Write is limited to instruction files under /tmp." ;;
    esac
    ;;
  Read | Edit | NotebookEdit | Glob | Grep | WebFetch | WebSearch | Workflow)
    deny "$TOOL is not allowed."
    ;;
esac
exit 0
