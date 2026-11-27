#!/usr/bin/env bash
# Print the pane on the first line and the text on the second, and exit 0, when the command on stdin is exactly one `herdr pane send-text <pane> '<text>'`; exit 1 otherwise.
set -u

CMD=$(cat)

# Control characters would let the text press Enter itself, so only text the user still has to submit passes
re="^herdr pane send-text ([^'[:space:]]+) '([^'[:cntrl:]]*)'\$"
[[ "$CMD" =~ $re ]] || exit 1
printf '%s\n%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
