#!/usr/bin/env bash
# Block replies to other people's GitHub comments so unreviewed agent prose never lands in their threads; top-level comments and reads stay allowed; input is one gh command per stdin line.
set -u

# normalize.sh splits a multi-line GraphQL query into lines that no longer start with `gh`, so match against the raw command pre-bash.sh exports
RAW_COMMAND="${AGENT_RAW_COMMAND:-}"
# REST replies go to /replies or carry in_reply_to
REST_REPLY_RE='/replies([?[:space:]]|$)|in_reply_to'
# GraphQL replies use the thread-reply mutation or an inReplyTo/replyToId input
GRAPHQL_REPLY_RE='addPullRequestReviewThreadReply|inReplyTo|replyToId'

deny() {
  printf 'Blocked: replying to GitHub comments is not allowed in agent sessions; show the draft reply to the user and let them post it.\n' >&2
  exit 2
}

# Print the HTTP method gh api would use: an explicit -X wins, otherwise any field or --input makes it POST, as gh does
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
    # A GraphQL request is always a POST, so only a mutation can write; a query that selects reply fields only reads
    "gh api graphql"|"gh api graphql "*)
      if printf '%s\n' "$SEG" "$RAW_COMMAND" | grep -q 'mutation' \
        && printf '%s\n' "$SEG" "$RAW_COMMAND" | grep -Eq "$GRAPHQL_REPLY_RE"; then
        deny
      fi
      ;;
    # A GET only reads, so a jq filter that mentions in_reply_to_id must not count as a reply
    "gh api "*)
      [ "$(rest_method "$SEG")" = "GET" ] && continue
      if printf '%s\n' "$SEG" "$RAW_COMMAND" | grep -Eq "$REST_REPLY_RE"; then
        deny
      fi
      ;;
  esac
done
exit 0
