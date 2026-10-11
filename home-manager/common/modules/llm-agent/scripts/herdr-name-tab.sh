#!/usr/bin/env bash
# UserPromptSubmit hook that names the herdr tab after the prompt; the arguments are the agent's print-mode command.
set -u

# The summarizer is the agent itself, so its own UserPromptSubmit must not recurse into this hook
[ -z "${HERDR_TAB_NAMING:-}" ] || exit 0
[ -n "${HERDR_TAB_ID:-}" ] || exit 0
command -v herdr >/dev/null 2>&1 || exit 0

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
  export HERDR_TAB_NAMING=1
  request="Reply with only a short tab title (at most 20 characters, no quotes, no explanation) for this request, in the request's language:

${PROMPT:0:2000}"
  label=$("$@" "$request" </dev/null 2>/dev/null | tr -d '\r' | sed -e '/^[[:space:]]*$/d' -e 's/^[[:space:]"「]*//' -e 's/[[:space:]"」]*$//' | head -n 1)
  label="${label:0:30}"
  [ -n "$label" ] || exit 0
  # F2 can land while the summary is generating, so recheck right before writing
  pinned && exit 0
  herdr tab rename "$HERDR_TAB_ID" "$label" >/dev/null 2>&1 || exit 0
  printf '%s\t%s\n' "$SESSION_ID" "$label" >"$state_file"
) </dev/null >/dev/null 2>&1 &

exit 0
