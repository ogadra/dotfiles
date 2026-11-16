#!/usr/bin/env bash
# Block @-mentions in GitHub comments the agent posts; PR bodies stay with block-pr-body.sh; input is one gh command per stdin line.
set -u

# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"

# REST endpoints that create issue, PR line, commit and review comments
REST_COMMENT_RE='/(comments|reviews)([/?[:space:]]|$)'
GRAPHQL_COMMENT_RE='add(Comment|DiscussionComment|PullRequestReview|PullRequestReviewComment|PullRequestReviewThread)([^A-Za-z]|$)'
# A word char, dot, plus or hyphen before @ makes it an email address, and $ makes it the shell's $@
MENTION_RE='(^|[^A-Za-z0-9_.+$-])@[A-Za-z0-9][A-Za-z0-9-]*'

deny() {
  printf 'Blocked: mentions in GitHub comments are not allowed in agent sessions.\n' >&2
  exit 2
}

# Drop what GitHub renders as code (fenced blocks and inline spans) and gh's own `-F key=@file` syntax, since neither notifies anyone
mention_text() {
  awk '/^[[:space:]]*```/ { fence = !fence; next } !fence' \
    | sed -E 's/`[^`]*`//g; s/(-F|--field)([[:space:]]+|=)[^[:space:]=]+=@[^[:space:]]*//g'
}

check() {
  if haystack "$1" | mention_text | grep -Eq "$MENTION_RE"; then
    deny
  fi
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "gh pr comment"*|"gh issue comment"*|"gh pr review"*)
      check "$SEG"
      ;;
    "gh api graphql"|"gh api graphql "*)
      HAY=$(haystack "$SEG")
      if printf '%s\n' "$HAY" | grep -q 'mutation' \
        && printf '%s\n' "$HAY" | grep -Eq "$GRAPHQL_COMMENT_RE"; then
        check "$SEG"
      fi
      ;;
    "gh api "*)
      [ "$(rest_method "$SEG")" = "POST" ] || continue
      if printf '%s\n' "$SEG" | grep -Eq "$REST_COMMENT_RE"; then
        check "$SEG"
      fi
      ;;
  esac
done
exit 0
