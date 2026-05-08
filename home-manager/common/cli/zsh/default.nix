{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    initContent = ''
      if [[ $- == *i* ]] && [[ -z "$CLAUDECODE" ]]; then
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };
}
