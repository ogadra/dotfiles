{ config, pkgs, ... }:
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
      copy() { ${if pkgs.stdenv.hostPlatform.isLinux then "wl-copy" else "pbcopy"} "$@"; }

      if [[ $options[zle] = on ]]; then
        source <(${config.programs.fzf.package}/bin/fzf --zsh | ${pkgs.gnused}/bin/sed 's/^  eval \(\$__fzf_[a-z_]*options\)$/  eval \1 2>\/dev\/null/')
      fi

      if [[ $- == *i* ]] && [[ -z "$CLAUDECODE" ]] && [[ -t 0 ]]; then
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };
}
