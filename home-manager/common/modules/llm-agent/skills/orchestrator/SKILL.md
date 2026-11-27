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

ユーザーの指示をレーンへ渡すときは、ユーザーが書いた文をそのまま送る。

- しないこと
    - 要約
    - 言い換え
    - 補足
    - 推敲
- 複数のレーンに関わる指示
    - レーンごとに、そのレーンに関わる文をそのまま切り出して送る

親が自分で実行するのは次のものだけにする。

- `herdr` コマンド
    - 使う操作
        - 「道具の使い分け」に挙げた操作
    - 引数
        - 展開済みの値を直書きする
- `ListAgents`
    - 自分のセッション名を調べる
- `SendMessage`
    - 作業レーンへ指示を送る
- 指示ファイルの書き込み
    - `/tmp` 配下にWriteツールで書く

## レーンの種類

| レーン | 数 | 役割 | 終了条件の既定値 |
| --- | --- | --- | --- |
| 作業レーン | タスクごとに1つ | 自分のworktreeでタスクを進める | `merged` の報告を受け、裏取りレーンがマージを確かめた |
| 調査レーン | タスクごとに1つ | 自分のworktreeで調べ、結果をファイルか報告で返す | `done` の報告をユーザーへ中継した |
| 裏取りレーン | 裏取りごとに1つ | 作業レーンの報告1件を `git` と `gh` で確かめる | `[orchestrator:verify ...]` の結果を受けた |

作業レーンと調査レーンの終了条件は、タスクごとに「2. タスク一覧を作って承認を取る」で決める。作業レーンは、PRのマージを裏取りレーンが確かめるまで閉じない。

## 道具の使い分け

初回の指示は `herdr agent start` の起動引数としてclaudeへ渡す。それ以外のメッセージは、向きを問わずClaude Codeの `SendMessage` で送る。

宛先は相手のセッション名にする。

- 親からレーンへ送るもの
    - 2回目以降の指示
- レーンから親へ送るもの
    - 報告

herdrは次の操作に使う。

- レーンを起動する
    - `herdr tab create`
    - `herdr agent start`
- レーンを閉じる
    - `herdr tab close`
- 画面を読む
    - `herdr agent read`
- 状態を調べる
    - `herdr agent get`
    - `herdr agent wait`
- タブ名を調べる
    - `herdr pane get`
    - `herdr tab get`
- 承認キーを送る
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
- 分岐元ブランチ
    - PRのbaseにする
- 指示文
    - やること
        - ユーザーの依頼文のうち、そのタスクに当たる文をそのまま書く
        - 入力がissue番号の場合
            - issue番号を書く
            - 本文はワーカーが `gh issue view` で読む
    - 完了条件
    - 報告規約
- 終了条件
    - 親がレーンを閉じる条件
    - 親が確かめられる出来事で書く
        - 例
            - `merged` の報告を受け、裏取りレーンがマージを確かめた
            - `done` の報告をユーザーへ中継した
    - 作業レーンの終了条件
        - PRのマージを裏取りレーンが確かめたことを含める
    - ユーザーの依頼に指定が無い場合
        - レーンの種類の既定値を使う

依存や担当範囲が曖昧なら、`AskUserQuestion` で分け方を聞く。分け方が決まったら、タスクごとの終了条件を含むタスク一覧をユーザーに見せて承認を取る。

この承認で、裏取りで一致したあとのpushとPR作成も承認されたものとして扱う。

ユーザーがPRを作らないよう指示したタスクでは、親とワーカーは末尾の「PRを作らないタスク」に従う。

調べるだけでコードを変えないタスクは調査レーンで進め、親とワーカーは末尾の「調査レーン」に従う。

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
        - 「レーンを起動しなおす」の手順に従う

#### レーンを起動しなおす

`herdr pane process-info <pane>` で、paneがshellへ戻っていることを確かめてから進める。

1. 指示ファイルのパスを渡したセッションを、対象リポジトリの履歴から探す
    - 次の `jq` でセッションIDを引く
        - `<履歴のディレクトリ名>` には、対象リポジトリの絶対パスの英数字以外を `-` に替えたものを入れる

    ```bash
    jq -rn --arg p "<指示ファイルの絶対パス>" '[inputs | select(.type == "user" and (.message.content | tostring | contains($p))) | {s: .sessionId, t: .timestamp}] | max_by(.t) | .s // empty' ~/.claude/projects/<履歴のディレクトリ名>/*.jsonl
    ```

2. 起動する
    - セッションIDが出た場合
        - 同じpaneでそのセッションを再開する

        ```bash
        herdr agent start <task_id> --kind claude --pane <pane> -- --resume <セッションID>
        ```

    - 何も出なかった場合
        - 同じpaneで、「3. 作業レーンを立てる」と同じ `herdr agent start` を実行する

### 4. 裏取りレーンを立てる

作業レーンの報告を確かめるたびに、新しい裏取りレーンを1つ立てる。

- 立て方
    - 作業レーンと同じ
    - `--label`
        - `verify-<task_id>`
    - 指示文
        - 「裏取りレーンへ渡す指示文の雛形」に、「6. 監視、裏取り、ユーザーへの中継」で挙げた確かめる内容を書き足す
- 閉じるとき
    - `[orchestrator:verify ...]` の結果を受けたら、`herdr tab close` で閉じる

### 5. レーンのセッション名を控える

作業レーンと調査レーンは、最初の報告に `ListAgents` で調べた自分のセッション名を書く。作業レーンは、ブランチ名とworktreeの絶対パスも書く。親はこれらをレーンごとに控え、以後の指示はその名前宛ての `SendMessage` で送る。

最初の報告にセッション名が無いレーンがあれば、親は「レーンを起動しなおす」の手順でそのレーンを起動しなおす。

### 6. 監視、裏取り、ユーザーへの中継

レーンごとにバックグラウンドBashで `herdr agent wait <pane>` を張る。イベントを処理したらwaitを張り直し、直後に `herdr agent get <pane>` で現在状態を直接確認する。

`<cross-session-message from="...">` に包まれた `[orchestrator:report ...]` 形式の報告が会話に届いたら、次の内容を指示文に書いた裏取りレーンを「4. 裏取りレーンを立てる」の手順で立て、`[orchestrator:verify ...]` の結果を受けてから次の行動を決める。

- `task_id`
- 対象リポジトリの絶対パス
- worktreeの絶対パス
- ブランチ名
- 分岐元ブランチ
- 報告の本文

#### コミットの裏取りからpushとPR作成まで

1. 作業レーンがコミットし、その一覧を `ready-to-push` で報告する
2. 親がその報告を確かめる裏取りレーンを立てる
3. 裏取りの結果で次の指示を決める
    - 一致した場合
        - 確かめたコミットのハッシュを控える
        - 作業レーンにpushを指示する
        - PRがまだ無い場合
            - PRの作成も指示する
    - 不一致の場合
        - 裏取りの根拠から直す点を書き、作業レーンへ送る
        - 作業レーンは直してコミットし、もう一度 `ready-to-push` で報告する
4. 作業レーンが報告する
    - pushした場合
        - `pushed` で報告する
    - PRを作った場合
        - `pr-created` で報告する
5. 親が報告を確かめる裏取りレーンを立てる
    - 確かめる報告
        - `pushed`
        - `pr-created`
    - 指示文に書き足すもの
        - 控えたハッシュ

#### 報告をユーザーへ中継する

`[orchestrator:verify ...]` が届くたびに、作業レーンの報告と、裏取りの結果と根拠を1件ずつまとめてユーザーへ書く。不一致なら、食い違った点も書く。

- ユーザーが決めることがある場合
    - まとめを書いた同じ返答の中で `AskUserQuestion` を呼ぶ
    - 1件を1問にする
- 決めることが無い場合
    - まとめだけで返答を終える

### 7. blockedと承認待ちを捌く

waitが返ったら `herdr agent read <pane> --source recent-unwrapped --lines 120` で画面を見て判断する。

- ワーカーのダイアログにある選択肢で足りる場合
    - `herdr agent send-keys <pane> enter` などの承認キーを送る
- pushの確認ダイアログの場合
    - 親がpushを指示したあと
        - 承認キーを送る
    - 親がpushを指示する前
        1. `herdr agent send-keys <pane> esc` でダイアログを閉じる
        2. `ready-to-push` で報告して止まるよう `SendMessage` で送る
- 自由記述の裁定が要る場合
    1. `herdr agent send-keys <pane> esc` でダイアログを閉じる
    2. 本文をレーンのセッション名宛てに `SendMessage` で送る
        - ユーザーが裁定した場合は、ユーザーの文をそのまま送る

1回の呼び出しで送る承認は1件だけにする。次のダイアログは `herdr agent read` で読んでから応答する。

#### ユーザーにレーンでの操作を頼む

ダイアログへの応答をユーザーに頼むときは、対象のレーンを、ユーザーがサイドバーで探せるタブ名で示す。タブ名はhookがプロンプトのたびに書き換えるので、頼む直前に次の順で取り直す。

1. `herdr pane get <pane>` の `.result.pane.tab_id` を読む
2. `herdr tab get <tab_id>` の `.result.tab.label` を読む

#### 承認代行の判定

- 親が応答して進める確認
    - 指示文に書いた作業の編集
    - テスト
    - 裏取りで一致したあとに親が指示したpush
    - 裏取りで一致したあとに親が指示したPR作成
    - ユーザーが指示したマージ
    - マージ後の後片付け
- 選択肢がある確認
    - 指示文やissueに判断の材料がある場合
        - 親が選ぶ
    - 材料が無い場合
        - `AskUserQuestion` でユーザーに選んでもらう
- `AskUserQuestion` でユーザーに聞く確認
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

親は、報告や裏取りの結果を処理するたびに、そのレーンの終了条件を満たしたかを照らし合わせる。満たしたら、ユーザーに確かめずに次の手順でレーンを閉じ、閉じたことをユーザーへの中継に書く。

作業レーンは次の順に閉じる。

1. ワーカーに後片付けを `SendMessage` で指示する
    - 指示文の雛形にある後片付けの手順に従わせる
2. ワーカーから `cleaned` の報告を受ける
3. 後片付けの結果を確かめる裏取りレーンを立てる
4. `herdr tab close` でタブを閉じる

ユーザーが自分でタブを閉じたら、親はそのレーンを控えた一覧から外す。

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
- 一時ファイルは mktemp 等で一意な名前を付けて作り、作業が終わっても残しておく（削除すると確認ダイアログが出て、ワーカーが承認を待って止まるため）
- コミットしたら push せずに "[orchestrator:report <task_id>] ready-to-push: <コミットの一覧と要約>" で報告して止まる
  - PRもまだ作らない
  - PRを作ったあとにコミットを足すときも、同じく push の前に報告して止まる
- 親から直しの指示が届いたら、直してコミットし、もう一度 ready-to-push で報告して止まる
- 親から push の指示が届いたら push し、"[orchestrator:report <task_id>] pushed: <ブランチ名> <pushした先端のコミット>" で報告して止まる
  - 初回は git push -u origin <ブランチ名> で push する（upstream が分岐元のままだと、分岐元へ push してしまうため）
- 親から PR 作成の指示が届いたら PR を作り、"[orchestrator:report <task_id>] pr-created: <PRのURL>" で報告して止まる
- 親からマージの指示が届いたらマージし、"[orchestrator:report <task_id>] merged: <PRのURL>" で報告する
- 親から後片付けの指示が届いたら、次の順に進めてから "[orchestrator:report <task_id>] cleaned: <要約>" で報告する
  - 親はPRのマージを確かめてから後片付けを指示するので、確認を挟まずに消す
  1. 対象リポジトリの絶対パスへ cd してworktreeを出る
  2. 分岐元のブランチを git pull でリモートに追従させる
  3. git worktree remove でworktreeを消す
  4. git branch -D で作業用ブランチを消す
```

## 裏取りレーンへ渡す指示文の雛形

```text
裏取りレーンの規約:
- 確かめる報告は1件で、この指示ファイルに task_id、対象リポジトリとworktreeの絶対パス、ブランチ名、分岐元ブランチと一緒に書いてある
- git -C <パス> status、git -C <パス> log、git -C <パス> worktree list、git -C <パス> branch、gh pr list --head <ブランチ名>、gh pr view で、報告と事実を突き合わせる
- ready-to-push の報告は、worktree のローカルのコミットを git -C <worktree> log、show、diff、status で確かめる
  - 結果には、確かめたブランチの先端のコミットのハッシュを書く
- pushed の報告は、git -C <worktree> ls-remote origin refs/heads/<ブランチ名> の先端が、指示ファイルに書いてあるハッシュと同じかだけを見る
- pr-created の報告は、次のものを見る
  - git -C <worktree> ls-remote origin refs/heads/<ブランチ名> の先端が、指示ファイルに書いてあるハッシュと同じか
  - gh pr view <PRのURL> --json baseRefName,headRefName,headRefOid,body で、base が分岐元ブランチ、head がブランチ名、headRefOid が指示ファイルに書いてあるハッシュと同じか
  - body が3行以内か
- リポジトリの状態を読むコマンドだけを使う
- 結果は SendMessage ツールで to に "<親のセッション名>"、message に "[orchestrator:verify <task_id>] <一致 / 不一致>: <根拠>" を渡して親へ送り、止まる
```

## レーンの沈黙と入力中に届いた報告

- イベントも報告も無いまま沈黙したレーン
    - `herdr agent get <pane>` で在否を確認する
    - 不在の場合
        - `herdr pane process-info <pane>` でshellへ戻ったことを確かめる
        - 次のコマンドをpaneへ送って復旧する
            - `env -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ID -u CLAUDE_CODE_BRIDGE_SESSION_ID -u CLAUDE_CODE_MESSAGING_SOCKET -u CLAUDE_CODE_MESSAGING_TOKEN -u CLAUDE_CODE_ENTRYPOINT claude --continue`
- 親が `AskUserQuestion` などで入力中にレーンの報告が届いた場合
    - 入力が終わってから報告を処理する

## PRを作らないタスク

- タスク一覧の承認
    - pushとPR作成の承認に含めない
- 作業レーンの規約
    - 次の行を消す
        - `ready-to-push` の行の下にある、PRに触れた2行
        - PR作成の指示の行
        - マージの行
    - 次の1行を足す
        - コミットせずに作業を終えたら "[orchestrator:report <task_id>] done: <要約>" で報告して止まる
- pushの指示を送る条件
    - 裏取りで一致した
    - ユーザーが `AskUserQuestion` でpushを承認した
- 終了条件の既定値
    - マージが無いので、作業レーンの「マージを確かめるまで閉じない」は当てはめない
    - 次のどれかを満たした
        - `pushed` の報告を裏取りレーンが確かめた
        - ユーザーが `AskUserQuestion` でpushを断った
        - `done` の報告をユーザーへ中継した
- 閉じる手順
    - `herdr tab close` でタブを閉じる
    - 残すもの
        - worktree
        - ブランチ

## 調査レーン

ワーカーはコミットもpushもせず、成果物はファイルか報告だけにする。

- 立て方
    - 「3. 作業レーンを立てる」と同じ
- 作業レーンの規約
    - 次の行を消す
        - `ready-to-push` の行と、その下にある2行
        - 直しの指示の行
        - pushの指示の行と、その下にある1行
        - PR作成の指示の行
        - マージの行
        - 後片付けの行と、その下にある手順
    - 次の2行を足す
        - 調べ終えたら "[orchestrator:report <task_id>] done: <結果の要約と成果物のファイルの絶対パス>" で報告して止まる
        - 報告の前にAskUserQuestionでユーザーへ質問しない。判断が要る点はdoneの報告に書いて親へ返す
- 裏取り
    - `done` の報告を確かめる裏取りレーンは立てない
    - 調査レーンだけのとき
        - 裏取りレーンを立てない
- 終了条件を満たしたときの閉じる手順
    1. `done` の報告の中身をユーザーへ書く
        - 判断が要る点が書かれている場合
            - 同じ返答の中で `AskUserQuestion` を呼ぶ
    2. `herdr tab close` でタブを閉じる
