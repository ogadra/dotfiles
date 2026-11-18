#!/usr/bin/env bash
# Block language toolchains that a base Linux system lacks so the agent runs them through Nix; input is one normalized command per stdin line.
set -u

# Matching by name instead of checking `command -v` keeps the result the same whether or not a toolchain happens to be on PATH
nix_attr() {
  case "$1" in
    go|gofmt) printf 'go' ;;
    node|npm|npx) printf 'nodejs' ;;
    pnpm|pnpx) printf 'pnpm' ;;
    yarn) printf 'yarn' ;;
    bun|bunx) printf 'bun' ;;
    deno) printf 'deno' ;;
    cargo) printf 'cargo' ;;
    rustc) printf 'rustc' ;;
    uv|uvx) printf 'uv' ;;
    *) return 1 ;;
  esac
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  CMD_NAME="${SEG%% *}"
  CMD_NAME="${CMD_NAME##*/}"
  ATTR=$(nix_attr "$CMD_NAME") || continue
  # normalize.sh splits on ; & | even inside quotes, so a chain under `bash -c` reaches here as bare segments
  cat >&2 <<EOF
Blocked: run ${CMD_NAME} through Nix in agent sessions.
- Project with a flake devShell: nix develop -c ${CMD_NAME} ...
- Otherwise: nix shell nixpkgs#${ATTR} -c ${CMD_NAME} ...
Give each command in a chain its own nix prefix.
EOF
  exit 2
done
exit 0
