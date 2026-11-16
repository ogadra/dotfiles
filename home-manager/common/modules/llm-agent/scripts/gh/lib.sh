#!/usr/bin/env bash
# Helpers the gh guards source; check.sh runs only block-*.sh, so this file never runs as a guard itself.

# normalize.sh splits a multi-line body or GraphQL query into lines that no longer start with `gh`, so guards match against the raw command pre-bash.sh exports
RAW_COMMAND="${AGENT_RAW_COMMAND:-}"

# gh api sends a POST once a field or --input is given
rest_method() {
  # shellcheck disable=SC2086
  set -- $1
  METHOD=""
  HAS_BODY=""
  while [ $# -gt 0 ]; do
    case "$1" in
      -X|--method) METHOD=${2:-}; shift ;;
      --method=*) METHOD=${1#--method=} ;;
      -X*) METHOD=${1#-X} ;;
      -f|-F|--field|--raw-field|--input|-f*|-F*|--field=*|--raw-field=*|--input=*) HAS_BODY=1 ;;
    esac
    shift
  done
  METHOD=$(printf '%s' "$METHOD" | tr -d "\"'" | tr '[:lower:]' '[:upper:]')
  if [ -n "$METHOD" ]; then
    printf '%s\n' "$METHOD"
  elif [ -n "$HAS_BODY" ]; then
    printf 'POST\n'
  else
    printf 'GET\n'
  fi
}

# gh reads `--input <file>`, `-F key=@<file>` and `--body-file <file>` itself, so the text can sit in a file the command line never shows; stdin (`-`) is already in the raw command as a heredoc or pipe
attached_files() {
  # shellcheck disable=SC2086
  set -- $1
  while [ $# -gt 0 ]; do
    case "$1" in
      --input|--body-file) printf '%s\n' "${2:-}"; shift ;;
      --input=*|--body-file=*) printf '%s\n' "${1#*=}" ;;
      # gh api takes `-F key=@file`, while gh pr comment, gh issue comment and gh pr review take `-F file` as the body file
      -F|--field)
        case "${2:-}" in
          *=@*) printf '%s\n' "${2#*=@}" ;;
          *=*) ;;
          *) printf '%s\n' "${2:-}" ;;
        esac
        shift
        ;;
      -F*=@*|--field=*=@*) printf '%s\n' "${1#*=@}" ;;
    esac
    shift
  done | tr -d "\"'" | grep -vx -- '-'
}

# Text to search: the segment, the raw command, and the files gh would read; relative paths resolve against the session cwd pre-bash.sh moved into
haystack() {
  printf '%s\n' "$1" "$RAW_COMMAND"
  attached_files "$1" | while IFS= read -r f; do
    [ -f "$f" ] && cat -- "$f"
  done
}
