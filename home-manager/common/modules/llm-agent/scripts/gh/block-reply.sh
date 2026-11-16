#!/usr/bin/env bash
# Block replies to other people's GitHub comments so unreviewed agent prose never lands in their threads; top-level comments and reads stay allowed; input is one gh command per stdin line.
set -u

# normalize.sh splits a multi-line GraphQL query into lines that no longer start with `gh`, so match against the raw command pre-bash.sh exports
RAW_COMMAND="${AGENT_RAW_COMMAND:-}"
REST_REPLY_RE='/replies([?[:space:]]|$)|in_reply_to'
GRAPHQL_REPLY_RE='addPullRequestReviewThreadReply|inReplyTo|replyToId'

deny() {
  printf 'Blocked: replying to GitHub review threads or other comment threads is not allowed in agent sessions; a normal comment with `gh pr comment` is still allowed.\n' >&2
  exit 2
}

# gh reads `--input <file>` and `-F key=@<file>` itself, so the reply fields can sit in a file the command line never shows; stdin (`-`) is already in the raw command as a heredoc or pipe
attached_files() {
  # shellcheck disable=SC2086
  set -- $1
  while [ $# -gt 0 ]; do
    case "$1" in
      --input) printf '%s\n' "${2:-}"; shift ;;
      --input=*) printf '%s\n' "${1#--input=}" ;;
      -F|--field) case "${2:-}" in *=@*) printf '%s\n' "${2#*=@}" ;; esac; shift ;;
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

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    # GraphQL always sends a POST, so only a mutation writes
    "gh api graphql"|"gh api graphql "*)
      HAY=$(haystack "$SEG")
      if printf '%s\n' "$HAY" | grep -q 'mutation' \
        && printf '%s\n' "$HAY" | grep -Eq "$GRAPHQL_REPLY_RE"; then
        deny
      fi
      ;;
    "gh api "*)
      [ "$(rest_method "$SEG")" = "GET" ] && continue
      if haystack "$SEG" | grep -Eq "$REST_REPLY_RE"; then
        deny
      fi
      ;;
  esac
done
exit 0
