{ pkgs }:
pkgs.replaceVars ./AGENTS.md {
  # Agents run commands in a non-interactive shell, so the fish abbr and zsh alias `copy` are unavailable.
  clipboardCommand = if pkgs.stdenv.hostPlatform.isLinux then "wl-copy" else "pbcopy";
}
