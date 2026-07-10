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

  HEAD="$NORM"
  for _ in 1 2 3 4 5; do
    if [[ "$HEAD" =~ ^[\(\{][[:space:]]*(.*)$ ]]; then
      HEAD="${BASH_REMATCH[1]}"
    elif [[ "$HEAD" =~ ^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+(.*)$ ]]; then
      HEAD="${BASH_REMATCH[1]}"
    elif [[ "$HEAD" =~ ^(xargs|command|exec|nohup|nice|env|time|sudo)[[:space:]]+(.*)$ ]]; then
      HEAD="${BASH_REMATCH[2]}"
    elif [[ "$HEAD" =~ ^\\(.*)$ ]]; then
      HEAD="${BASH_REMATCH[1]}"
    else
      break
    fi
  done

  ADD_RE='^git[[:space:]]+add([[:space:]]|$)'
  FLAG_RE='(^|[[:space:]])(-A|--all|-u|--update)([[:space:])}]|$)'
  DOT_RE='(^|[[:space:]])\.([[:space:])}]|$)'
  if [[ "$HEAD" =~ $ADD_RE ]] \
    && { [[ "$HEAD" =~ $FLAG_RE ]] || [[ "$HEAD" =~ $DOT_RE ]]; }; then
    deny "bulk git add is not allowed; inspect and stage explicit files."
  fi
done < <(printf '%s\n' "$CMD" | tr ';&|' '\n')

for check in git/check.sh gh/check.sh; do
  printf '%s' "$INPUT" | "$SCRIPT_DIR/$check"
  rc=$?
  [ "$rc" -ne 0 ] && exit "$rc"
done

exit 0
