#!/usr/bin/env bash
set -euo pipefail

profile="${1:?usage: bootstrap-darwin.sh <profile>}"
repo_dir="$HOME/codes/github.com/ogadra/dotfiles"
nix_flags=(--extra-experimental-features "nix-command flakes")

if [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
  installer=$(mktemp /tmp/nix-install-XXXXXX)
  curl -fsSL https://nixos.org/nix/install -o "$installer"
  sh "$installer" --daemon
  rm -f "$installer"
fi
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

if [ ! -d "$repo_dir" ]; then
  mkdir -p "$(dirname "$repo_dir")"
  nix "${nix_flags[@]}" run nixpkgs#git -- clone https://github.com/ogadra/dotfiles.git "$repo_dir"
fi

for f in /etc/bashrc /etc/zshrc /etc/nix/nix.conf; do
  if [ -f "$f" ] && [ ! -L "$f" ]; then
    sudo mv "$f" "$f.before-nix-darwin"
  fi
done

src=$(nix "${nix_flags[@]}" flake archive --json "$repo_dir" | nix "${nix_flags[@]}" run nixpkgs#jq -- -r .path)
sudo "$(command -v nix)" "${nix_flags[@]}" run nix-darwin -- switch --flake "$src#$profile"
