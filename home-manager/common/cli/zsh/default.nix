{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;

    # Secrets and machine-local variables live outside the repository.
    envExtra = ''
      [[ -f "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
    '';

    initContent = ''
      rm() { ${pkgs.gomi}/bin/gomi "$@"; }

      if [[ $- == *i* ]] && [[ -z "$CLAUDECODE" ]]; then
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };
}
