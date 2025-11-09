function ghq-fzf
    set src (ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 (ghq root)/{}/README.*")
    if test -n "$src"
        cd (ghq root)/$src
    end
end

# Ctrl+g で実行するキーバインドを登録
bind \cg ghq-fzf
