# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Dotfiles managed by **Nix Flakes + Home Manager** (primary) with **chezmoi** as legacy fallback for Linux-only configs.

Machine profiles:
- `bisharp` (x86_64-linux, NixOS, KDE Plasma 6)
- `latias` (x86_64-darwin, macOS)
- `stakataka` (aarch64-darwin, macOS)

## Build Commands

```bash
make build    # Build configuration
make switch   # Apply configuration (first run auto-installs Nix and nix-darwin)
make update   # Update all flake inputs
```

## Development Tools

gitleaks and lefthook are provided via `devShells` in flake.nix. Use `nix develop` or direnv (`use flake` in .envrc) to activate them.

## Architecture

```
.
├── flake.nix                # Entry point
├── nixos/                   # NixOS system settings
├── darwin/                  # macOS system settings (nix-darwin)
├── profiles/                # Machine-specific system profiles
├── home-manager/            # User environment settings
│   ├── common/              # Cross-platform
│   │   ├── apps/            # GUI (wezterm, vscode, etc.)
│   │   └── cli/             # CLI (fish, git, starship, etc.)
│   ├── nixos/               # Linux-specific (kwin, wofi, etc.)
│   └── profiles/            # Machine-specific user profiles
├── private_dot_config/      # chezmoi-managed (legacy, Linux-only)
└── data/                    # Config data
```

## Key Patterns

- Machine profiles are in `profiles/<hostname>/` and `home-manager/profiles/<hostname>/`
- New CLI tools go in `home-manager/common/cli/<toolname>/default.nix`
- New GUI apps go in `home-manager/common/apps/<category>/<appname>/`
- Platform-specific configs go in `home-manager/nixos/` (Linux)
- Some files in `home-manager/profiles/stakataka/` have skip-worktree set to protect local-only changes from being committed

## Git Workflow

- Pre-commit hook runs `gitleaks protect --staged -v` for secrets detection
- Default branch: `main`
