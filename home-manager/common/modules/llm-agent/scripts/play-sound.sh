#!/usr/bin/env bash
set -u

sound_path="${1:-}"
[ -n "$sound_path" ] || exit 0

(mpv --no-terminal --volume=30 "$sound_path" </dev/null >/dev/null 2>&1 &)
