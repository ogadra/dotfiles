#!/usr/bin/env bash
# Send a turn that reports something as unchecked back to check it, or to state why it could not be checked.
set -u

INPUT=$(cat)
# The stop right after this hook's own block passes, so a reply that must still mention the phrase costs one extra turn instead of a loop
[ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')" = true ] && exit 0

# The whole message counts, since an unchecked item can sit anywhere in a report; reading the transcript instead would race its write at Stop
printf '%s' "$INPUT" | jq -r '.last_assistant_message // ""' | grep -qE '(確かめ|確認し)て(い)?ません' || exit 0

printf "Blocked: the reply says something was not checked. Check it now, or if you cannot, report the concrete reason (e.g. the command was denied, no permission, no network) instead of only saying it was not checked.\n" >&2
exit 2
