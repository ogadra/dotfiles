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
  NORM=$(printf '%s' "$SEG" | tr -s '[:space:]' ' ')
  NORM="${NORM% }"

  case "$NORM" in
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

  if [[ "$NORM" =~ (^|[^[:alnum:]_])git[[:space:]]+add([^[:alnum:]_]|$) ]] \
    && { [[ "$NORM" =~ (^|[^[:alnum:]_-])(-A|--all|-u|--update)([^[:alnum:]_-]|$) ]] \
      || [[ "$NORM" =~ (^|[[:space:]])\.([[:space:]]|$) ]]; }; then
    deny "bulk git add is not allowed; inspect and stage explicit files."
  fi
done < <(printf '%s\n' "$CMD" | tr ';&|' '\n')

for check in git/check.sh gh/check.sh; do
  printf '%s' "$INPUT" | "$SCRIPT_DIR/$check"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done

exit 0
