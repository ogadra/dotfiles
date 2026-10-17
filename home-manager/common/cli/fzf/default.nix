{ ... }:
{
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    # Sourced manually in zsh initContent to silence the read-only `zle` option error.
    enableZshIntegration = false;
  };
}
