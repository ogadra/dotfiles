---
name: orchestrator
description: herdr 上の別 pane で claude などのワーカーレーンを起動し、複数タスクの割り振り・監視・承認代行・報告集約を親として一括で行う。「issue 3をやってほしい」「この3件を並列でやらせて」「ワーカーに振って」「レーンで進めて」「レーンを見て」と依頼されたとき、または /orchestrator で明示起動されたときに使う。HERDR_ENV=1 必須。
user-invocable: true
---

# orchestrator

親として、複数のワーカーレーンへのタスク割り振りと運用を一括で担う。
ユーザーは親にだけ話せばよい。

最初に `test "${HERDR_ENV:-}" = 1` を確認し、失敗したらherdr管理下でない旨を伝えて停止する。

## 道具の使い分け

- 指示と報告
    - ファイルに書いて `herdr agent prompt` で送る
- 画面の確認
    - `herdr agent read`
- 生死の確認
    - `herdr agent get`
- 事実の確認
    - `git`
    - `gh`

ワーカーの自己申告は必ず裏を取ってから扱う。

## 流れ

### 1. 親名を付ける

ワーカーは報告をherdrのエージェント名宛てに送る。名前は一意で短いものにする。

```bash
herdr agent rename "$HERDR_PANE_ID" orc-<短い名>   # 例: orc-skills
```

セッションを再開したときとレーンを復旧したときは、同じ名前で付け直す。親がワーカーへ渡す報告規約にこの名前を書き込むので、一字でも違うと報告が届かない。

### 2. タスク一覧を作って承認を取る

issue番号、自由文のタスク、計画のいずれかを読み、タスクごとに次を決める。

- `task_id`
    - 短い識別子
    - pane、ブランチ、報告の命名に使う
- `branch` と `base`
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

同一リポジトリ内の並列作業はworktreeで分ける。

```bash
git worktree add -b <branch> <repo>/.claude/worktrees/<task_id> <base>
herdr tab create --workspace <ws> --cwd <repo>/.claude/worktrees/<task_id> --label <task_id> --no-focus
# 出力の root_pane.pane_id を控える（監視・承認で使う）
herdr agent start <task_id> --kind claude --pane <pane>
```

worktreeは対象リポジトリの `.claude/worktrees/` 直下に置く。

- `<repo>`
    - 親リポジトリの絶対パスを書く
- パスの渡し方
    - 展開済みの絶対パスを直書きする
- `.claude/worktrees/` がignore対象でない場合
    - `.git/info/exclude` に追記してから作成する

レーンを別workspaceに分ける場合は、`herdr tab create` の代わりに `herdr workspace create --cwd <path> --label <task_id> --no-focus` を使う。

指示文はファイルに書いてから、その中身を送る。

```bash
herdr agent prompt <pane> "$(cat <指示ファイル>)"
```

指示ファイルはWriteツールで書く。

### 4. 監視する

レーンごとにバックグラウンドBashで `herdr agent wait <pane>` を張る。waitは既定でidle、done、blockedのいずれかに達すると返り、その終了が起床通知になる。イベントを処理したらwaitを張り直し、直後に `herdr agent get <pane>` で現在状態を直接確認する。

`[orchestrator:report ...]` 形式の報告が会話に届いたら、ワーカーの自己申告として扱う。`gh pr list --head <branch>` や `git status`、`git log` で裏を取ってから次の行動を決める。

### 5. blockedと承認待ちを捌く

waitが返ったら `herdr agent read <pane> --source recent-unwrapped --lines 120` で画面を見て判断する。

- 提示された選択肢で足りる場合
    - `herdr agent send-keys <pane> enter` などの承認キーを送る
- 自由記述の裁定が要る場合
    - `send-keys <pane> esc` でダイアログを閉じてから、`agent prompt` で本文を送る

1回の呼び出しで送る承認は1件だけにする。次のダイアログを先読みして重ねて送ると、読んでいない選択肢を誤確定する。

#### 承認代行の判定

| 状況 | 対応 |
| --- | --- |
| 計画に書かれた編集、テスト、承認済みのpush/PR作成 | 親が応答して進める |
| 計画内だが選択肢がある確認 | 指示文やissueの記述から判断する。材料が無ければユーザーへ上げる |
| スコープ拡大、前提との食い違い、未承認の外部影響 | ユーザーへ上げる |

### 6. 軌道修正と追加指示

指示ファイルを書いて `herdr agent prompt <pane> "$(cat <file>)"` で送る。send-keysは承認キーにだけ使う。誤って選択肢を確定したら、ワーカーがその結果をコミットする前に訂正指示を送る。

### 7. 完了判定と後始末

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
- 完了・ブロック・承認が要る判断に出くわしたら、止まる直前に
  `herdr agent prompt orc-<名> "[orchestrator:report <task_id>] <状態>: <要約>"` で親へ報告する
- 一時ファイルは消さない（削除の確認ダイアログがレーンを止める。名前の衝突は mktemp 等の一意名で避ける）
- <push・PR 作成は承認済みの前提で進めてよい / push・PR 作成の前に「承認待ち」で報告して親の応答を待つ>
```

## レーンの沈黙と報告の取りこぼし

- イベントも報告も無いまま沈黙したレーン
    - `herdr agent get <pane>` で在否を確認する
    - 不在の場合
        - `herdr pane process-info <pane>` でshellへ戻ったことを確かめる
        - 次のコマンドをpaneへ送って復旧する
            - `env -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ID -u CLAUDE_CODE_BRIDGE_SESSION_ID -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN -u CLAUDE_CODE_ENTRYPOINT claude --continue`
        - `env -u` を付けないと、起動したclaudeが親の `CLAUDE_CODE_*` を引き継いで自分を親の子プロセスとみなす
- 親がAskUserQuestionなどで入力中に届いたワーカー報告
    - herdrが `agent_blocked` で拒否するので、会話に現れない
    - 対話から戻ったら `agent wait` を張り直して取りこぼしを拾う
