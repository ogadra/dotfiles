#!/usr/bin/env bash
# PreToolUse(Bash) hook entry for LLM coding agents.
set -u

INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""')

# Guards that query repository state need to run where the command would run, and a failed cd just leaves them in the hook's directory
if [ -n "$CWD" ]; then
  cd "$CWD" 2>/dev/null || true
fi

SEGMENTS=$(printf '%s' "$CMD" | "$SCRIPT_DIR/normalize.sh")

deny() {
  printf 'Blocked: %s\n' "$1" >&2
  exit 2
}

while IFS= read -r SEG; do
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
  esac

  ADD_RE='^git[[:space:]]+add([[:space:]]|$)'
  FLAG_RE='(^|[[:space:]])(-A|--all|-u|--update)([[:space:])}]|$)'
  DOT_RE='(^|[[:space:]])\.([[:space:])}]|$)'
  if [[ "$SEG" =~ $ADD_RE ]] \
    && { [[ "$SEG" =~ $FLAG_RE ]] || [[ "$SEG" =~ $DOT_RE ]]; }; then
    deny "bulk git add is not allowed; inspect and stage explicit files."
  fi
done <<< "$SEGMENTS"

for check in git/check.sh gh/check.sh; do
  printf '%s\n' "$SEGMENTS" | "$SCRIPT_DIR/$check"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done

exit 0
