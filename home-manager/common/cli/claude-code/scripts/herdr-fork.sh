#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
[ "$(jq -r '.prompt' <<<"$input")" = "/fork" ] || exit 0

if [ "${HERDR_ENV:-}" != "1" ]; then
  jq -n '{decision: "block", reason: "/fork needs a herdr pane"}'
  exit 0
fi

session_id=$(jq -r '.session_id' <<<"$input")
cwd=$(jq -r '.cwd' <<<"$input")
pane_id=$(herdr tab create --cwd "$cwd" --no-focus | jq -r '.result.root_pane.pane_id')
herdr pane run "$pane_id" "claude --resume $session_id --fork-session" >/dev/null

jq -n --arg pane "$pane_id" '{decision: "block", reason: "Forked into herdr pane \($pane)"}'
