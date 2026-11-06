#!/usr/bin/env bash
# Block replies to other people's GitHub comments so unreviewed agent prose never lands in their threads; top-level comments stay allowed; input is one gh command per stdin line.
set -u

# normalize.sh splits a multi-line GraphQL query into lines that no longer start with `gh`, so match against the raw command pre-bash.sh exports
RAW_COMMAND="${AGENT_RAW_COMMAND:-}"
# REST replies go to /replies or carry in_reply_to; GraphQL replies use the thread-reply mutation or an inReplyTo/replyToId input
REPLY_RE='/replies([?[:space:]]|$)|in_reply_to|addPullRequestReviewThreadReply|inReplyTo|replyToId'

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "gh api "*)
      if printf '%s\n' "$SEG" "$RAW_COMMAND" | grep -Eq "$REPLY_RE"; then
        printf 'Blocked: replying to GitHub comments is not allowed in agent sessions; show the draft reply to the user and let them post it.\n' >&2
        exit 2
      fi
      ;;
  esac
done
exit 0
