#!/usr/bin/env bash
# UserPromptSubmit hook that names the herdr tab after a summary of the prompt; the arguments are extra flags for `agent -p`.
set -u

[ -n "${HERDR_TAB_ID:-}" ] || exit 0
command -v herdr >/dev/null 2>&1 || exit 0

# Hooks may run under a wrapper shell, so climb past shells to the agent process itself
agent_args() {
  local pid=$PPID comm
  while [ "$pid" -gt 1 ]; do
    comm=$(ps -o comm= -p "$pid" | sed 's|.*/||; s/^-//')
    case "$comm" in
    sh | bash | zsh | dash) pid=$(ps -o ppid= -p "$pid" | tr -d ' ') ;;
    *)
      ps -o args= -p "$pid"
      return
      ;;
    esac
  done
}

# Print-mode runs (scripts, other agents, and this hook's own summarizer) share the pane's HERDR_TAB_ID but are not the session the tab belongs to
case " $(agent_args) " in
*" -p "* | *" --print "*) exit 0 ;;
esac

INPUT=$(cat)
PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // ""')
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""')
[ -n "$PROMPT" ] || exit 0

state_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/herdr-tab-names"
mkdir -p "$state_dir"
state_file="$state_dir/${HERDR_SESSION:-default}_${HERDR_TAB_ID//[^[:alnum:]]/_}"

current_label() {
  herdr tab get "$HERDR_TAB_ID" 2>/dev/null | jq -r '.result.tab.label // ""'
}

# A label that differs from the last one written here means F2 renamed the tab, which pins it for the rest of the agent session
pinned() {
  [ -f "$state_file" ] || return 1
  local saved_session saved_label
  IFS=$'\t' read -r saved_session saved_label <"$state_file"
  [ "$saved_session" = "$SESSION_ID" ] || return 1
  [ "$(current_label)" != "$saved_label" ]
}

pinned && exit 0

# Summarizing takes seconds, so it runs detached instead of holding up the prompt
(
  # Devin has no flag to disable hooks, so its sound hooks read this to stay silent in the summarizer
  export HERDR_TAB_NAMING=1
  request="次の依頼で実行する内容を1行で短く要約してください。要約だけを出力してください。

${PROMPT:0:2000}"
  # agent is the zsh function that dispatches to the CLI of the session that spawned it
  label=$(zsh -c 'agent "$@"' agent -p "$request" "$@" </dev/null 2>/dev/null | tr -d '\r' | sed -e '/^[[:space:]]*$/d' -e 's/^[[:space:]"「]*//' -e 's/[[:space:]"」]*$//' | head -n 1)
  label="${label:0:30}"
  [ -n "$label" ] || exit 0
  # F2 can land while the summary is generating, so recheck right before writing
  pinned && exit 0
  herdr tab rename "$HERDR_TAB_ID" "$label" >/dev/null 2>&1 || exit 0
  printf '%s\t%s\n' "$SESSION_ID" "$label" >"$state_file"
) </dev/null >/dev/null 2>&1 &

exit 0
