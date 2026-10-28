{ pkgs, questions }:
pkgs.replaceVars ./AGENTS.md {
  # Agents run commands in a non-interactive shell, so the fish abbr and zsh alias `copy` are unavailable.
  clipboardCommand = if pkgs.stdenv.hostPlatform.isLinux then "wl-copy" else "pbcopy";
  # Each agent names a different question tool with a different schema, so the rules come from the agent's own module.
  questions = pkgs.lib.removeSuffix "\n" (builtins.readFile questions);
}
