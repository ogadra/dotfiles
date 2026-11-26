#!/usr/bin/env bash
# Send a turn that ends by asking the user in prose back to ask with AskUserQuestion.
set -u

# claude -p sets CLAUDE_CODE_SESSION_ATTENDED=0, and nobody is there to answer a question
[ "${CLAUDE_CODE_SESSION_ATTENDED:-}" = 1 ] || exit 0

INPUT=$(cat)
# The stop right after this hook's own block passes, so a false match costs one extra turn instead of a loop
[ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')" = true ] && exit 0

# Only the tail counts, since a question earlier in a report is not what the reply ends on; reading the transcript instead would race its write at Stop
TAIL=$(printf '%s' "$INPUT" | jq -r '.last_assistant_message // ""' | tail -n 8)
printf '%s' "$TAIL" | grep -qE '決めて(いただ|くだ)|判断を?(ください|いただ|お願い)|指示を(ください|いただ|お願い)|指示して(ください|いただ)|(よければ|良ければ|よろしければ)|(ます|ましょう)か(？|\?)|(よろしい|いかが|よい|いい)で(す|しょう)か|[Ss]hould I |[Dd]o you want me to|[Ww]ould you like me to|[Ll]et me know (if|whether|which|how)' || exit 0

printf "Blocked: the reply ends by asking the user in prose. Ask with AskUserQuestion instead, with \"<step>\" and \"Do not <step>\" as the two options when asking whether to do the next step, or end the turn as is if nothing needs the user's decision.\n" >&2
exit 2
