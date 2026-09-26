{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;

    # Secrets and machine-local variables live outside the repository.
    envExtra = ''
      [[ -f "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
    ''
    # agent() must live in .zshenv so `zsh -c` callers (which skip .zshrc) see it.
    + builtins.readFile ./agent.zsh;

    initContent = ''
      rm() { ${pkgs.gomi}/bin/gomi "$@"; }

      if [[ $- == *i* ]] && [[ -z "$CLAUDECODE" ]]; then
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };
}
