#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# result symlinks are GC roots that pin the closure
find "$repo_root" -maxdepth 1 -type l \( -name result -o -name 'result-*' \) -delete

# Scratch dirs are named after the shell PID, so a dead PID means abandoned
for dir in /tmp/nix-develop-* /tmp/nix-shell-*; do
  [ -d "$dir" ] || continue
  pid=$(basename "$dir" | cut -d- -f3)
  case "$pid" in
    '' | *[!0-9]*) ;;
    *) kill -0 "$pid" 2>/dev/null && continue ;;
  esac
  rm -rf "$dir"
done

# Build sandboxes carry no PID, so fall back to age
find /tmp -maxdepth 1 -type d -name 'nix-build-*' -mtime +1 -exec rm -rf {} +

# -d drops every generation but the current one, so rollback is no longer possible
nix-collect-garbage -d
sudo nix-collect-garbage -d
