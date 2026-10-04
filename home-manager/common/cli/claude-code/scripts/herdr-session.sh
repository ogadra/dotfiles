#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
[ -n "${HERDR_PANE_ID:-}" ] || exit 0

# wezterm's fork key reads this file to resume the focused pane's session; keep the path in sync with wezterm/keybinds.nix
dir="$HOME/.local/state/herdr-claude/$HERDR_SESSION"
file="$dir/$HERDR_PANE_ID"

case "$(jq -r '.hook_event_name' <<<"$input")" in
  SessionStart)
    mkdir -p "$dir"
    jq -r '.session_id, .cwd, .transcript_path' <<<"$input" >"$file"
    ;;
  # /clear ends one session and starts another, so only the session that wrote the file removes it
  SessionEnd)
    if [ "$(head -n 1 "$file" 2>/dev/null)" = "$(jq -r '.session_id' <<<"$input")" ]; then
      rm -f "$file"
    fi
    ;;
esac
