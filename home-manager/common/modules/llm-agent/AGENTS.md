# AGENTS.md

## Git

- `git add` を実行する前
    - `git status` で変更を確かめる
    - `git diff` で変更を確かめる
- gitで管理しているファイルは `git rm` で消す
- コミットメッセージ
    - 英語で書く
    - 先頭にConventional Commitsのprefixを付ける
        - `feat:`
        - `fix:`
        - `docs:`
        - `style:`
        - `refactor:`
        - `test:`
        - `chore:`
- 1コミットは、件名1行で変更の全体を言える大きさに収める

## Pull Request

- PRのbody
    - 変更したことだけを書く
    - 3行以内に収める

## 何をどこに書くか

- アプリケーションコード
    - コードにはどう動くかを書く
- テストコード
    - コードには確かめる振る舞いを書く

## コメント

- 書いてよいもの
    - ユーザーの承認を得たもの
- 書く内容
    - コードから読み取れない意図
- コメントを書き換えるとき
    - 修正履歴に読めないよう、コメント全体を書き直す

## ユーザーに実行してもらうコマンド

- `herdr pane send-text` で入力欄に入れる
    - Enterは送らず、ユーザーが押す
    - 文字列は単引用符で囲む
    - `cd` は入れない
- `sudo` が要らないコマンド
    - 自分のpaneの入力欄に、先頭に `!` を付けて入れる
        - pane
            - `herdr pane current` の `.result.pane.pane_id`
    - `herdr pane send-text <pane> '! <コマンド>'`
    - 入れる前に、入力欄が空かを確かめる
        - `herdr pane read <pane> --source visible` で読む
        - 文が入っている場合
            - 入れずに、送るか消すようユーザーに頼む
    - 別のディレクトリで実行するコマンド
        - `git -C <ディレクトリ>` や絶対パスで、ディレクトリを引数に書く
- `sudo` が要るコマンド
    - 別タブのshellに入れる
    1. `herdr tab create --workspace <ws> --cwd <実行するディレクトリ> --label cmd --no-focus` でタブを作る
        - ws
            - `herdr pane current` の `.result.pane.workspace_id`
    2. 出力の `root_pane.pane_id` へ `herdr pane send-text <pane> '<コマンド>'` で入れる
    3. タブ名 `cmd` をユーザーに伝える

## ユーザーへの質問

@questions@

@RTK.md
