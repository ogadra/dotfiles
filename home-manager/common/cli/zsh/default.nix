{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    initContent = ''
      rm() { ${pkgs.gomi}/bin/gomi "$@"; }

      if [[ $- == *i* ]] && [[ -z "$CLAUDECODE" ]]; then
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };
}
