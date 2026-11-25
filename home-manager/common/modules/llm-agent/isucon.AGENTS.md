# AGENTS.md

## ユーザーに実行してもらうコマンド

- `herdr pane send-text` で入力欄に入れる
    - Enterは送らず、ユーザーが押す
    - 文字列は単引用符で囲む
    - `cd` は入れない
- 自分のcwdで実行でき、`sudo` が要らないコマンド
    - 自分のpaneの入力欄に、先頭に `!` を付けて入れる
        - pane
            - `herdr pane current` の `.result.pane.pane_id`
    - `herdr pane send-text <pane> '! <コマンド>'`
- `sudo` が要るコマンド、または別のディレクトリで実行するコマンド
    - 別タブのshellに入れる
    1. `herdr tab create --workspace <ws> --cwd <実行するディレクトリ> --label cmd --no-focus` でタブを作る
        - ws
            - `herdr pane current` の `.result.pane.workspace_id`
    2. 出力の `root_pane.pane_id` へ `herdr pane send-text <pane> '<コマンド>'` で入れる
    3. タブ名 `cmd` をユーザーに伝える

## ユーザーへの質問

@questions@
