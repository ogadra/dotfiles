#!/usr/bin/env bash
# PostToolUse hook that appends a newline when the written file does not already end in one.
set -u

INPUT=$(cat)

FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""')

# A nonexistent or empty file needs nothing
[ -n "$FILE_PATH" ] && [ -s "$FILE_PATH" ] && [ -n "$(tail -c1 "$FILE_PATH")" ] && echo >> "$FILE_PATH"
exit 0
