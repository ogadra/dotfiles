#!/usr/bin/env bash
# PreToolUse(Bash) hook entry for LLM coding agents.
set -u

INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')

deny() {
  printf 'Blocked: %s\n' "$1" >&2
  exit 2
}

while IFS= read -r SEG; do
  SEG="${SEG#"${SEG%%[![:space:]]*}"}"
  [ -n "$SEG" ] || continue

  case "$SEG" in
    sudo|"sudo "*)
      deny "sudo is not allowed in Codex sessions."
      ;;
    "find "*"-delete"*)
      deny "find -delete is not allowed in Codex sessions."
      ;;
    "xargs rm"|"xargs rm "*)
      deny "xargs rm is not allowed in Codex sessions."
      ;;
    "git commit -a"|"git commit -a "*)
      deny "git commit -a is not allowed; stage files intentionally."
      ;;
    "git add ."|"git add -u"|"git add -A")
      deny "bulk git add is not allowed; inspect and stage explicit files."
      ;;
  esac
done < <(printf '%s\n' "$CMD" | tr ';&|' '\n')

for check in git/check.sh gh/check.sh; do
  printf '%s' "$INPUT" | "$SCRIPT_DIR/$check"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done

exit 0
