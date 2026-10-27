---
name: orchestrator
description: herdr 上の別 pane で claude などのワーカーレーンを起動し、複数タスクの割り振り・監視・承認代行・報告集約を親として一括で行う。「issue 3をやってほしい」「この3件を並列でやらせて」「ワーカーに振って」「レーンで進めて」「レーンを見て」と依頼されたとき、または /orchestrator で明示起動されたときに使う。HERDR_ENV=1 必須。
user-invocable: true
---

# orchestrator

親として、複数のワーカーレーンへのタスク割り振りと運用を一括で担う。
ユーザーは親にだけ話せばよい。

最初に `test "${HERDR_ENV:-}" = 1` を確認し、失敗したら、herdrのpane内で起動し直すようユーザーへ伝えて停止する。

## 親とワーカーの分担

親は入力待ちの状態を保ち、作業はすべて別タブのワーカーへすぐに渡す。単純なシェルスクリプトやコマンドの実行も渡す。

親が自分で実行するのは次のものだけにする。このスキルを起動したセッションでは、hookが次のツール呼び出しだけを通す。

- `herdr` コマンド
    - 「道具の使い分け」に挙げた操作
    - 引数は展開済みの値を直書きする
- `ListAgents`
    - 自分のセッション名の確認
- `SendMessage`
    - ワーカーへの送信
        - 指示
        - 裁定
        - 連絡
- タスク一覧の材料集め
    - `gh issue view`
- ワーカーの報告の裏取り
    - `git status`
    - `git log`
    - `gh pr list`
- 指示ファイルの書き込み
    - `/tmp` 配下にWriteツールで書く

渡す先のレーンがない場合は、一時的なタブを立てる。

1. `herdr tab create` でタブを立てる
2. `herdr agent start` でワーカーを起動して作業を渡す
3. 完了を確かめてから `herdr tab close` で閉じる

## 道具の使い分け

メッセージの受け渡しは、向きを問わずClaude Codeの `SendMessage` で行う。

- 親からワーカーへ送るもの
    - 初回の指示
        - `herdr agent start` の起動引数としてclaudeへ渡す
    - 次のものは、ワーカーのセッション名宛てに `SendMessage` で送る
        - 2回目以降の指示
        - 裁定
        - 連絡
- ワーカーから親へ送るもの
    - 報告
        - 親のセッション名宛てに `SendMessage` で送る

herdrは次の操作に使う。

- レーンの起動と終了
    - `herdr tab create`
    - `herdr agent start`
    - `herdr tab close`
    - `herdr workspace close`
- 画面の確認
    - `herdr agent read`
- 状態の確認
    - `herdr agent get`
    - `herdr agent wait`
- 承認キーの送信
    - `herdr agent send-keys`

ワーカーの報告の裏取りには `git` と `gh` を使う。

## 流れ

### 1. 親のセッション名を控える

ワーカーは報告を親のClaude Codeセッション名宛てに `SendMessage` で送る。`ListAgents` を呼び、出力先頭の `This session is <名> [<ref>]` の `<名>` を控える。

控えた名前は、ワーカーへ渡す報告規約の `<親のセッション名>` に一字違わず書き込む。セッションを再開したときは `ListAgents` で名前を確かめ直し、変わっていたら稼働中の全レーンへ新しい名前を `SendMessage` で伝える。

### 2. タスク一覧を作って承認を取る

issue番号、自由文のタスク、計画のいずれかを読み、タスクごとに次を決める。

- `task_id`
    - 短い識別子
    - pane、ブランチ、報告の命名に使う
- `branch`
- `base`
- 指示文
    - やること
    - 完了条件
    - 報告規約
    - 入力がissue番号の場合
        - `gh issue view` で本文を取って材料にする
- 完了の出口
    - 実装まで
    - PR作成まで
    - push/PRまでやる場合
        - この承認が実行承認を兼ねる

依存や担当範囲が曖昧なら、ユーザーへ問う。

### 3. レーンを立てて起動する

タスクごとに、タブとエージェントを新しく立ててレーンにする。別のissueや別の依頼は、別のタスクとして扱う。

同一リポジトリ内の並列作業はworktreeで分ける。

```bash
git worktree add -b <branch> <repo>/.claude/worktrees/<task_id> <base>
herdr tab create --workspace <ws> --cwd <repo>/.claude/worktrees/<task_id> --label <task_id> --no-focus
# 出力の root_pane.pane_id を控える（監視・承認で使う）
herdr agent start <task_id> --kind claude --pane <pane> -- "<指示ファイルの絶対パス> を読んで従ってください"
```

worktreeは対象リポジトリの `.claude/worktrees/` 直下に置く。

- `<repo>`
    - 親リポジトリの絶対パスを書く
- パスの渡し方
    - 展開済みの絶対パスを直書きする
- `.claude/worktrees/` がignore対象でない場合
    - `.git/info/exclude` に追記してから作成する

レーンを別workspaceに分ける場合は、`herdr tab create` の代わりに `herdr workspace create --cwd <path> --label <task_id> --no-focus` を使う。

初回の指示は、`herdr agent start` の `--` 以降にclaudeの起動引数として渡す。

- 起動引数で渡す理由
    - 親がワーカーのセッション名を知るのは、ワーカーの最初の報告を受けたあとになる
- 起動引数
    - 指示ファイルのパスを読ませる1行だけにする
        - 指示文そのものは複数行なので、herdrが `agent arguments cannot be encoded safely for the target shell` で拒否する
- `herdr agent start` がtimeoutを返した場合
    - `herdr agent get <pane>` でclaudeが起動したかを確かめる
    - 起動していた場合
        - 進む
    - 起動していなかった場合
        - ユーザーへ報告し、そのレーンについてユーザーの判断を待つ

指示ファイルはWriteツールで `/tmp` 配下に書く。

### 4. ワーカーのセッション名を控える

ワーカーは最初の報告に、`ListAgents` で調べた自分のセッション名を書く。親はそれをレーンごとに控え、以後の指示はその名前宛ての `SendMessage` で送る。

最初の報告にセッション名が無いレーンは、ユーザーへ報告し、そのレーンについてユーザーの判断を待つ。

### 5. 監視する

レーンごとにバックグラウンドBashで `herdr agent wait <pane>` を張る。waitは既定でidle、done、blockedのいずれかに達すると返り、その終了が起床通知になる。イベントを処理したらwaitを張り直し、直後に `herdr agent get <pane>` で現在状態を直接確認する。

`<cross-session-message from="...">` に包まれた `[orchestrator:report ...]` 形式の報告が会話に届いたら、ワーカーの自己申告として扱う。`gh pr list --head <branch>` や `git status`、`git log` で裏を取ってから次の行動を決める。

### 6. blockedと承認待ちを捌く

waitが返ったら `herdr agent read <pane> --source recent-unwrapped --lines 120` で画面を見て判断する。

- 提示された選択肢で足りる場合
    - `herdr agent send-keys <pane> enter` などの承認キーを送る
- 自由記述の裁定が要る場合
    - `herdr agent send-keys <pane> esc` でダイアログを閉じてから、本文をワーカーのセッション名宛てに `SendMessage` で送る

1回の呼び出しで送る承認は1件だけにする。次のダイアログは `herdr agent read` で読んでから応答する。

#### 承認代行の判定

| 状況 | 対応 |
| --- | --- |
| 計画に書かれた編集、テスト、承認済みのpush/PR作成 | 親が応答して進める |
| 計画内だが選択肢がある確認 | 指示文やissueの記述から判断する。材料が無ければユーザーへ上げる |
| スコープ拡大、前提との食い違い、未承認の外部影響 | ユーザーへ上げる |

### 7. 軌道修正と追加指示

本文をワーカーのセッション名宛てに `SendMessage` で送る。send-keysは承認キーにだけ使う。誤って選択肢を確定したら、ワーカーがその結果をコミットする前に訂正指示を送る。

同じタスクの続きは、そのタスクのレーンへ送ってよい。

- 同じタスクの続き
    - 修正指示
    - そのタスクのPRのマージ
    - そのタスクについての追加調査

### 8. 完了判定と後始末

完了は差分の事実で判定する。

- 未コミットの変更
    - `git status`
- コミット
    - `git log`
- PR
    - `gh pr list --head <branch>`

全レーンが完了したら、`herdr workspace close <ws>` で自分が立てたworkspaceを閉じる。worktreeとブランチは、削除対象を列挙してユーザーの承認を取ってから消す。

## ワーカーへ渡す指示文の雛形

指示文は「やること」と「完了条件」のあとに、次の規約セクションを連結する。

```text
作業レーンの規約:
- 作業を始める前にまず ListAgents で自分のセッション名を調べ、SendMessage ツールで to に "<親のセッション名>"、message に "[orchestrator:report <task_id>] started: session=<自分のセッション名>" を渡して親へ報告する
- 以後、親からの指示は SendMessage で届く
- 完了・ブロック・承認が要る判断に出くわしたら、止まる直前に
  SendMessageツールで to に "<親のセッション名>"、message に "[orchestrator:report <task_id>] <状態>: <要約>" を渡して親へ報告する
- 一時ファイルは mktemp 等で一意な名前を付けて作り、作業が終わっても残しておく（削除の確認ダイアログがレーンを止めるため）
- <push・PR 作成は承認済みの前提で進めてよい / push・PR 作成の前に「承認待ち」で報告して親の応答を待つ>
```

## レーンの沈黙と報告の取りこぼし

- イベントも報告も無いまま沈黙したレーン
    - `herdr agent get <pane>` で在否を確認する
    - 不在の場合
        - `herdr pane process-info <pane>` でshellへ戻ったことを確かめる
        - 次のコマンドをpaneへ送って復旧する
            - `env -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ID -u CLAUDE_CODE_BRIDGE_SESSION_ID -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN -u CLAUDE_CODE_ENTRYPOINT claude --continue`
                - `env -u` で親の `CLAUDE_CODE_*` を外し、起動したclaudeを親から独立したセッションにする
- 親がAskUserQuestionなどで入力中にワーカーの報告が届いた場合
    - 入力が終わるまで報告を待たせてよい
        - 親のClaude Codeが報告をキューに積み、次のツール呼び出しの区切りで会話へ渡す
