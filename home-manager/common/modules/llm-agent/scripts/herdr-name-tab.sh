#!/usr/bin/env bash
set -u

[ -n "${HERDR_TAB_ID:-}" ] || exit 0
[ -z "${HERDR_TAB_NAMING:-}" ] || exit 0
command -v herdr >/dev/null 2>&1 || exit 0

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

case " $(agent_args) " in
*" -p "* | *" --print "*) exit 0 ;;
esac

INPUT=$(cat)
PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // ""')
REPLY=$(printf '%s' "$INPUT" | jq -r '.last_assistant_message // ""')
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""')

state_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/herdr-tab-names"
mkdir -p "$state_dir"
state_file="$state_dir/${HERDR_SESSION:-default}_${HERDR_TAB_ID//[^[:alnum:]]/_}"
history_file="$state_dir/history_${SESSION_ID//[^[:alnum:]-]/_}.jsonl"

remember() {
  jq -cn --arg role "$1" --arg text "${2:0:1000}" '{role: $role, text: $text}' >>"$history_file"
  tail -n 6 "$history_file" >"$history_file.tmp" && mv "$history_file.tmp" "$history_file"
}

if [ -z "$PROMPT" ]; then
  [ -n "$REPLY" ] && remember agent "$REPLY"
  exit 0
fi

conversation=$(
  [ -f "$history_file" ] && jq -r 'if .role == "user" then "ユーザー: " else "エージェント: " end + .text' "$history_file"
  printf 'ユーザー（最新）: %s\n' "${PROMPT:0:2000}"
)
remember user "$PROMPT"

current_label() {
  herdr tab get "$HERDR_TAB_ID" 2>/dev/null | jq -r '.result.tab.label // ""'
}

pinned() {
  [ -f "$state_file" ] || return 1
  local saved_session saved_label
  IFS=$'\t' read -r saved_session saved_label <"$state_file"
  [ "$saved_session" = "$SESSION_ID" ] || return 1
  [ "$(current_label)" != "$saved_label" ]
}

pinned && exit 0

(
  export HERDR_TAB_NAMING=1
  request="次はユーザーとAIエージェントの会話です。ユーザーの最新の依頼で実行する内容を1行で短く要約してください。要約だけを出力してください。

${conversation}"
  label=$(zsh -c 'agent "$@"' agent -p "$request" "$@" </dev/null 2>/dev/null | tr -d '\r' | sed -e '/^[[:space:]]*$/d' -e 's/^[[:space:]"「]*//' -e 's/[[:space:]"」]*$//' | head -n 1)
  label="${label:0:30}"
  [ -n "$label" ] || exit 0
  pinned && exit 0
  herdr tab rename "$HERDR_TAB_ID" "$label" >/dev/null 2>&1 || exit 0
  printf '%s\t%s\n' "$SESSION_ID" "$label" >"$state_file"
) </dev/null >/dev/null 2>&1 &

exit 0
