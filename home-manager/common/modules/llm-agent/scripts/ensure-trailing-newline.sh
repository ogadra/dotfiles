#!/usr/bin/env bash
# PostToolUse hook that appends a newline when the written file does not already end in one.
set -u

INPUT=$(cat)

# NotebookEdit names its target notebook_path, every other file-writing tool uses file_path
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""')

# A nonexistent or empty file needs nothing
[ -n "$FILE_PATH" ] && [ -s "$FILE_PATH" ] && [ -n "$(tail -c1 "$FILE_PATH")" ] && echo >> "$FILE_PATH"
exit 0
