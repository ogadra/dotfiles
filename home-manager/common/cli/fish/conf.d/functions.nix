{ ... }:
{
  programs.fish.interactiveShellInit = ''
    function ghq-fzf
      set src (ghq list | fzf --preview "sh -c 'bat --color=always --style=header,grid --line-range :80 \$(ghq root)/\$1/README.* 2>/dev/null' _ {}")
      if test -n "$src"
        cd (ghq root)/$src
      end
    end

    # Ctrl+g で ghq-fzf を実行
    bind \cg ghq-fzf
  '';
}
