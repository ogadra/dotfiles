{ ... }:
{
  programs.fish.interactiveShellInit = ''
    function ghq-fzf
      set src (ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 (ghq root)/{}/README.*")
      if test -n "$src"
        cd (ghq root)/$src
      end
    end

    # Ctrl+g で ghq-fzf を実行
    bind \cg ghq-fzf
  '';
}
