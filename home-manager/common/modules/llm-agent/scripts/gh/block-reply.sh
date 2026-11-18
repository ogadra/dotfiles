#!/usr/bin/env bash
# Block replies to other people's GitHub comments so unreviewed agent prose never lands in their threads; top-level comments and reads stay allowed; input is one gh command per stdin line.
set -u

# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"

REST_REPLY_RE='/replies([?[:space:]]|$)|in_reply_to'
GRAPHQL_REPLY_RE='addPullRequestReviewThreadReply|inReplyTo|replyToId'

deny() {
  printf 'Blocked: replying to GitHub review threads or other comment threads is not allowed in agent sessions.\n' >&2
  exit 2
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
