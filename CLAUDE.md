# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Dotfiles managed by Nix Flakes + Home Manager.

Machine profiles:
- `bisharp` (x86_64-linux, NixOS, KDE Plasma 6)
- `latias` (x86_64-darwin, macOS)
- `stakataka` (aarch64-darwin, macOS)

`private_dot_config/` was managed by chezmoi and is being phased out. New configs go through Nix; do not add files there.

## Build Commands

```bash
make build    # Build configuration
make update   # Update all flake inputs
```

## Key Patterns

- Machine profiles are in `profiles/<hostname>/` and `home-manager/profiles/<hostname>/`
- New CLI tools go in `home-manager/common/cli/<toolname>/default.nix`
- New GUI apps go in `home-manager/common/apps/<category>/<appname>/`
- Platform-specific configs go in `home-manager/nixos/` (Linux)
- Some files in `home-manager/profiles/stakataka/` have skip-worktree set to protect local-only changes from being committed
- Do not add informational/diagnostic `echo` to Nix scripts. Functional uses of `echo` (piping data to another command, appending a newline to a file) are fine.

## Comments

- Write comments in English
- Keep a comment on one line
- Write a comment for each of these
    - The reason you chose a value
    - The effect of a settings property
    - Accepted values
    - Units
    - Ranges
    - Version caveats
