#!/usr/bin/env bash
# Block replies to other people's GitHub comments so unreviewed agent prose never lands in their threads; top-level comments and reads stay allowed; input is one gh command per stdin line.
set -u

# normalize.sh splits a multi-line GraphQL query into lines that no longer start with `gh`, so match against the raw command pre-bash.sh exports
RAW_COMMAND="${AGENT_RAW_COMMAND:-}"
REST_REPLY_RE='/replies([?[:space:]]|$)|in_reply_to'
GRAPHQL_REPLY_RE='addPullRequestReviewThreadReply|inReplyTo|replyToId'

deny() {
  printf 'Blocked: replying to GitHub comments is not allowed in agent sessions; show the draft reply to the user and let them post it.\n' >&2
  exit 2
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
      if printf '%s\n' "$SEG" "$RAW_COMMAND" | grep -q 'mutation' \
        && printf '%s\n' "$SEG" "$RAW_COMMAND" | grep -Eq "$GRAPHQL_REPLY_RE"; then
        deny
      fi
      ;;
    "gh api "*)
      [ "$(rest_method "$SEG")" = "GET" ] && continue
      if printf '%s\n' "$SEG" "$RAW_COMMAND" | grep -Eq "$REST_REPLY_RE"; then
        deny
      fi
      ;;
  esac
done
exit 0
