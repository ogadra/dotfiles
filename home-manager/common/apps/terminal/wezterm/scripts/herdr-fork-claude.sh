session=$1

read -r pane_id workspace_id < <(
  herdr --session "$session" pane list |
    jq -r '.result.panes[] | select(.focused) | "\(.pane_id) \(.workspace_id)"'
)

file="$HOME/.local/state/herdr-claude/$session/$pane_id"
[ -f "$file" ] || exit 0

{
  read -r session_id
  read -r cwd
} <"$file"

new_pane=$(
  herdr --session "$session" tab create --workspace "$workspace_id" --cwd "$cwd" --no-focus |
    jq -r '.result.root_pane.pane_id'
)

herdr --session "$session" pane run "$new_pane" "claude --resume $session_id --fork-session" >/dev/null
