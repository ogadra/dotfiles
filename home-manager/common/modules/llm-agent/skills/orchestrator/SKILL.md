---
name: orchestrator
description: herdr 上の別 pane で claude などのワーカーレーンを起動し、複数タスクの割り振り・監視・承認代行・報告集約を親として一括で行う。「issue 3をやってほしい」「この3件を並列でやらせて」「ワーカーに振って」「レーンで進めて」「レーンを見て」とユーザーが依頼したとき、またはユーザーが /orchestrator と打ったときに使う。HERDR_ENV=1 必須。
user-invocable: true
---

# orchestrator

## 親の仕事

親は入力待ちの状態を保ち、依頼ごとに渡す先だけを決める。

- 稼働中のレーンに渡す
    - そのレーンのセッション名宛てに `SendMessage` で送る
- 新しいレーンを立てて渡す
    - 「3. 作業レーンを立てる」の手順で立てる

親が自分で実行するのは次のものだけにする。

- `herdr` コマンド
    - 「道具の使い分け」に挙げた操作
    - 引数は展開済みの値を直書きする
- `ListAgents`
    - 自分のセッション名の確認
- `SendMessage`
    - 作業レーンへの指示
    - 裏取りレーンへの依頼
- 指示ファイルの書き込み
    - `/tmp` 配下にWriteツールで書く

## レーンの種類

| レーン | 数 | 役割 | 閉じる条件 |
| --- | --- | --- | --- |
| 作業レーン | タスクごとに1つ | 自分のworktreeでタスクを進める | 「10. レーンを閉じる」のきっかけを得たとき |
| 裏取りレーン | 1つ | 作業レーンの報告を `git` と `gh` で確かめる | 作業レーンをすべて閉じたとき |

## 道具の使い分け

初回の指示は `herdr agent start` の起動引数としてclaudeへ渡す。それ以外のメッセージは、向きを問わずClaude Codeの `SendMessage` で送る。

宛先は相手のセッション名にする。

- 親からレーンへ送るもの
    - 2回目以降の指示
    - 裏取りの依頼
- レーンから親へ送るもの
    - 報告

herdrは次の操作に使う。

- レーンの起動と終了
    - `herdr tab create`
    - `herdr agent start`
    - `herdr tab close`
- 画面の確認
    - `herdr agent read`
- 状態の確認
    - `herdr agent get`
    - `herdr agent wait`
- 承認キーの送信
    - `herdr agent send-keys`

## 流れ

### 1. 親のセッション名を控える

`ListAgents` を呼び、出力先頭の `This session is <名> [<ref>]` の `<名>` を控える。

控えた名前は、レーンへ渡す報告規約の `<親のセッション名>` に一字違わず書き込む。セッションを再開したときは `ListAgents` で名前を確かめ直し、変わっていたら稼働中の全レーンへ新しい名前を `SendMessage` で伝える。

### 2. タスク一覧を作って承認を取る

ユーザーの依頼をタスクに分け、タスクごとに次を決める。別のissueや別の依頼は、別のタスクにする。

- `task_id`
    - 短い識別子
    - 次の命名に使う
        - pane
        - worktree
        - 報告
- 対象リポジトリ
    - 絶対パス
- 指示文
    - やること
        - 入力がissue番号の場合
            - issue番号を書く
            - 本文はワーカーが `gh issue view` で読む
    - 完了条件
    - 報告規約

依存や担当範囲が曖昧なら、ユーザーへ問う。

この承認をpushとPR作成の承認とする。

ユーザーがPRを作らないよう指示したタスクは、末尾の「PRを作らないタスク」に従う。

### 3. 作業レーンを立てる

```bash
herdr tab create --workspace <ws> --cwd <対象リポジトリの絶対パス> --label <task_id> --no-focus
# 出力の root_pane.pane_id を控える（監視・承認で使う）
herdr agent start <task_id> --kind claude --pane <pane> -- "<指示ファイルの絶対パス> を読んで従ってください"
```

- 起動引数
    - 指示ファイルのパスを読ませる1行だけにする
- `herdr agent start` がtimeoutを返した場合
    - `herdr agent get <pane>` でclaudeが起動したかを確かめる
    - 起動していた場合
        - 進む
    - 起動していなかった場合
        1. ユーザーへ報告する
        2. そのレーンについてユーザーの判断を待つ

### 4. 裏取りレーンを立てる

最初の作業レーンの直後に立てる。立て方は作業レーンと同じで、`--label` は `verify`、指示文は「裏取りレーンへ渡す指示文の雛形」を使う。

### 5. レーンのセッション名を控える

レーンは最初の報告に、`ListAgents` で調べた自分のセッション名を書く。作業レーンは、ブランチ名とworktreeの絶対パスも書く。親はこれらをレーンごとに控え、以後の指示はその名前宛ての `SendMessage` で送る。

最初の報告にセッション名が無いレーンがあれば、親はユーザーへ報告し、そのレーンについてユーザーの判断を待つ。

### 6. 監視と裏取り

レーンごとにバックグラウンドBashで `herdr agent wait <pane>` を張る。イベントを処理したらwaitを張り直し、直後に `herdr agent get <pane>` で現在状態を直接確認する。

`<cross-session-message from="...">` に包まれた `[orchestrator:report ...]` 形式の報告が会話に届いたら、次の内容を裏取りレーンへ `SendMessage` で送り、`[orchestrator:verify ...]` の結果を受けてから次の行動を決める。

- `task_id`
- 対象リポジトリの絶対パス
- worktreeの絶対パス
- ブランチ名
- 報告の本文

### 7. blockedと承認待ちを捌く

waitが返ったら `herdr agent read <pane> --source recent-unwrapped --lines 120` で画面を見て判断する。

- ワーカーのダイアログにある選択肢で足りる場合
    - `herdr agent send-keys <pane> enter` などの承認キーを送る
- 自由記述の裁定が要る場合
    1. `herdr agent send-keys <pane> esc` でダイアログを閉じる
    2. 本文をレーンのセッション名宛てに `SendMessage` で送る

1回の呼び出しで送る承認は1件だけにする。次のダイアログは `herdr agent read` で読んでから応答する。

#### 承認代行の判定

- 親が応答して進める確認
    - 指示文に書いた作業の編集
    - テスト
    - 承認済みのpush
    - 承認済みのPR作成
    - ユーザーが指示したマージ
    - マージ後の後片付け
- 選択肢がある確認
    - 指示文やissueに判断の材料がある場合
        - 親が選ぶ
    - 材料が無い場合
        - ユーザーへ上げる
- ユーザーへ上げる確認
    - スコープ拡大
    - 前提との食い違い
    - 未承認の外部影響

### 8. 軌道修正と追加指示

次のものは、そのタスクのレーンのセッション名宛てに `SendMessage` で送る。

- 修正指示
- そのタスクについての追加調査

誤って選択肢を確定したら、ワーカーがその結果をコミットする前に訂正指示を送る。

### 9. マージする

1. ユーザーがマージを指示する
2. 親が、そのタスクのレーンへマージの指示を `SendMessage` で送る
3. ワーカーがマージし、`merged` で報告する

### 10. レーンを閉じる

親は、次の両方がそろったら作業レーンを閉じる。

- ワーカーから `merged` の報告を受けた
- 裏取りレーンがマージを確かめた

1. ワーカーに後片付けを `SendMessage` で指示する
    - 指示文の雛形にある後片付けの手順に従わせる
2. ワーカーから `cleaned` の報告を受ける
3. 裏取りレーンに後片付けの結果を確かめさせる
4. `herdr tab close` でタブを閉じる

ユーザーが自分でタブを閉じたら、親はそのレーンを控えた一覧から外す。

作業レーンをすべて閉じたら、裏取りレーンを `herdr tab close` で閉じる。

## ワーカーへ渡す指示文の雛形

指示文は「やること」と「完了条件」のあとに、次の規約セクションを連結する。

```text
作業レーンの規約:
- 最初に、<対象リポジトリの絶対パス>/.claude/worktrees/<task_id> に作業用ブランチのworktreeを作り、その中で作業する
  - .claude/worktrees/ がignore対象でなければ、.git/info/exclude に追記してから作る
- 次に ListAgents で自分のセッション名を調べ、SendMessage ツールで to に "<親のセッション名>"、message に "[orchestrator:report <task_id>] started: session=<自分のセッション名> branch=<ブランチ名> worktree=<worktreeの絶対パス>" を渡して親へ報告する
- 以後、親からの指示は SendMessage で届く
- 完了・ブロック・承認が要る判断に出くわしたら、止まる直前に
  SendMessageツールで to に "<親のセッション名>"、message に "[orchestrator:report <task_id>] <状態>: <要約>" を渡して親へ報告する
- 一時ファイルは mktemp 等で一意な名前を付けて作り、作業が終わっても残しておく（削除の確認ダイアログがレーンを止めるため）
- push と PR 作成は承認済みとして進める
- PRを作ったら "[orchestrator:report <task_id>] pr-created: <PRのURL>" で報告して止まる
- 親からマージの指示が届いたらマージし、"[orchestrator:report <task_id>] merged: <PRのURL>" で報告する
- 親から後片付けの指示が届いたら、次の順に進めてから "[orchestrator:report <task_id>] cleaned: <要約>" で報告する
  - 指示はPRのマージを親が確かめてから届くので、確認を挟まずに消す
  1. 対象リポジトリの絶対パスへ cd してworktreeを出る
  2. 分岐元のブランチを git pull でリモートに追従させる
  3. git worktree remove でworktreeを消す
  4. git branch -D で作業用ブランチを消す
```

## 裏取りレーンへ渡す指示文の雛形

```text
裏取りレーンの規約:
- 最初に ListAgents で自分のセッション名を調べ、SendMessage ツールで to に "<親のセッション名>"、message に "[orchestrator:verify] started: session=<自分のセッション名>" を渡して親へ報告する
- 親から SendMessage で、task_id、対象リポジトリとworktreeの絶対パス、ブランチ名、確かめる報告が届く
- git -C <パス> status、git -C <パス> log、git -C <パス> worktree list、git -C <パス> branch、gh pr list --head <ブランチ名>、gh pr view で、報告と事実を突き合わせる
- リポジトリの状態を読むコマンドだけを使う
- 結果は SendMessage ツールで to に "<親のセッション名>"、message に "[orchestrator:verify <task_id>] <一致 / 不一致>: <根拠>" を渡して親へ送る
```

## レーンの沈黙と入力中に届いた報告

- イベントも報告も無いまま沈黙したレーン
    - `herdr agent get <pane>` で在否を確認する
    - 不在の場合
        - `herdr pane process-info <pane>` でshellへ戻ったことを確かめる
        - 次のコマンドをpaneへ送って復旧する
            - `env -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ID -u CLAUDE_CODE_BRIDGE_SESSION_ID -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN -u CLAUDE_CODE_ENTRYPOINT claude --continue`
- 親がAskUserQuestionなどで入力中にレーンの報告が届いた場合
    - 入力が終わってから報告を処理する

## PRを作らないタスク

- タスク一覧の承認
    - pushとPR作成の承認に含めない
- 作業レーンの規約
    - 次の3行を消す
        - pushとPR作成の行
        - PRを作ったときの報告の行
        - マージの行
    - 代わりに次の1行を書く
        - 実装を終えたら "[orchestrator:report <task_id>] done: <要約>" で報告して止まる
- レーンを閉じるきっかけ
    - ユーザーが閉じるよう指示したとき
- 閉じる手順
    - `herdr tab close` でタブを閉じる
    - worktreeとブランチは残す
