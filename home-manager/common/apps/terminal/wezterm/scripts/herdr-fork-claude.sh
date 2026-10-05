session=$1

read -r pane_id workspace_id < <(
  herdr --session "$session" pane list |
    jq -r '.result.panes[] | select(.focused) | "\(.pane_id) \(.workspace_id)"'
)

# Claude Code writes a live per-pid session registry, so the pane's claude pid resolves its session
mapfile -t pids < <(
  herdr --session "$session" pane process-info --pane "$pane_id" |
    jq -r '.result.process_info.foreground_processes[].pid'
)
session_file=
for pid in "${pids[@]}"; do
  f="$HOME/.claude/sessions/$pid.json"
  [ -f "$f" ] && session_file=$f && break
done
# ponytail: silently does nothing when the registry layout changes or no claude runs in the pane
[ -n "$session_file" ] || exit 0

mapfile -t info < <(jq -r '.sessionId, .cwd' "$session_file")
session_id=${info[0]}
cwd=${info[1]}

# Forking an empty session is pointless, so the transcript must hold at least one user message
transcript=$(find "$HOME/.claude/projects" -name "$session_id.jsonl" -print -quit)
grep -q '"type":"user"' "$transcript" 2>/dev/null || exit 0

new_pane=$(
  herdr --session "$session" tab create --workspace "$workspace_id" --cwd "$cwd" --no-focus |
    jq -r '.result.root_pane.pane_id'
)

herdr --session "$session" pane run "$new_pane" "claude --resume $session_id --fork-session" >/dev/null
