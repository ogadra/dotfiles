#!/usr/bin/env bash
# Agent hook that copies the pane's terminal title, which the agent sets from the conversation, onto the herdr tab label.
set -u

[ -n "${HERDR_TAB_ID:-}" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0
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

# Print-mode runs (scripts, other agents) share the pane's HERDR_TAB_ID but are not the session the tab belongs to
case " $(agent_args) " in
*" -p "* | *" --print "*) exit 0 ;;
esac

SESSION_ID=$(jq -r '.session_id // ""')

state_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/herdr-tab-names"
mkdir -p "$state_dir"
state_file="$state_dir/${HERDR_SESSION:-default}_${HERDR_TAB_ID//[^[:alnum:]]/_}"

label=$(herdr pane get "$HERDR_PANE_ID" 2>/dev/null | jq -r '.result.pane.terminal_title_stripped // ""')
[ -n "$label" ] || exit 0

current=$(herdr tab get "$HERDR_TAB_ID" 2>/dev/null | jq -r '.result.tab.label // ""')

# A label that differs from the last one written here means F2 renamed the tab, which pins it for the rest of the agent session
if [ -f "$state_file" ]; then
  IFS=$'\t' read -r saved_session saved_label <"$state_file"
  [ "$saved_session" = "$SESSION_ID" ] && [ "$current" != "$saved_label" ] && exit 0
fi

[ "$current" = "$label" ] || herdr tab rename "$HERDR_TAB_ID" "$label" >/dev/null 2>&1 || exit 0
printf '%s\t%s\n' "$SESSION_ID" "$label" >"$state_file"
