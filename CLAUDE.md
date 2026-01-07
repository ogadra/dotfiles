# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a hybrid dotfiles system using:
- **Nix Flakes + Home Manager** for NixOS (primary)
- **Nix Flakes + nix-darwin + Home Manager** for macOS
- **Chezmoi** for non-Nix systems (fallback)

Machine profiles:
- `bisharp` (x86_64-linux, KDE Plasma 6)
- `latias` (x86_64-darwin, macOS)

## Build Commands

```bash
make build    # Build configuration
make switch   # Apply configuration
```

### Initial Darwin Setup
```bash
# Install Nix (if not installed)
sh <(curl -L https://nixos.org/nix/install)

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# First-time bootstrap
nix run nix-darwin -- switch --flake .#latias
```

### Chezmoi (fallback for non-Nix systems)
```bash
chezmoi init --apply ogadra  # Initial setup
chezmoi diff                 # Preview changes
chezmoi apply                # Apply changes
```

## Architecture

```
flake.nix                    # Nix flakes entry point
├── nixos/
│   ├── configuration.nix    # Base NixOS system config
│   ├── default.nix          # System builder
│   └── settings/            # Modular settings (desktop, nix-ld, security, shell)
├── darwin/
│   ├── configuration.nix    # Base darwin config (with Homebrew integration)
│   └── default.nix          # System builder
├── profiles/
│   ├── bisharp/             # NixOS machine profile
│   └── latias/              # Darwin machine profile
├── home-manager/
│   ├── default.nix          # Home Manager module config
│   ├── common/              # Platform-independent configs
│   │   ├── apps/            # GUI apps (wezterm, vscode, discord)
│   │   └── cli/             # CLI tools (claude-code, fish, git, starship, etc.)
│   ├── nixos/               # Linux-specific (kwin, clipboard, wofi)
│   └── profiles/
│       ├── bisharp/         # NixOS HM profile
│       └── latias/          # Darwin HM profile
├── private_dot_config/      # Chezmoi-managed configs
├── data/                    # YAML config data (gitconfig, paths)
└── init/                    # Initialization scripts (Brewfile, fonts)
```

## Key Patterns

- Machine profiles are in `profiles/<hostname>/` and `home-manager/profiles/<hostname>/`
- New CLI tools go in `home-manager/common/cli/<toolname>/default.nix`
- New GUI apps go in `home-manager/common/apps/<category>/<appname>/`
- Platform-specific configs go in `home-manager/nixos/` (Linux) or `home-manager/darwin/` (macOS)

## Git Workflow

- Pre-commit hook runs `gitleaks protect --staged -v` for secrets detection
- Commits are auto-signed with SSH key (Ed25519)
- Default branch: `main`

## Claude Code Permissions (configured in repo)

**Allowed:**
- `git push origin:<branch>`, `git push -u origin:<branch>`

**Denied:**
- Recursive/force delete commands (`rm -rf`, `rm -r`, etc.)
- Broad git operations (`git add .`, `git add -u`, `git commit --no-verify`)
- Direct push to main/master/production
- `sudo` commands

When committing, add files individually rather than using `git add .` or `git add -u`.
