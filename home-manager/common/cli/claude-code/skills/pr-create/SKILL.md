---
name: pr-create
description: GitHubのPull Requestを作る、または既存PRのbodyを直す。ユーザーが「PRを作る」「PR出して」「PRのbodyを直して」と言ったとき、`/pr-create` で呼ばれたとき、または `gh pr create` や `gh pr edit --body` がhookにブロックされたときに使う。Creates or edits a GitHub pull request with a three-line body.
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(git push:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh repo view:*), Bash($HOME/.claude/scripts/gh/pr-body.sh:*), Read, Write
---

# PR Create

`gh pr create` と `gh pr edit --body` はhookがブロックする。PRの作成とbodyの変更は `~/.claude/scripts/gh/pr-body.sh` 経由でのみできる。

## PR bodyの条件

やったことを3行以内で書く。空行は数えない。

次は書かない。

- 理由
- 見出し
- 動作確認
- 変更ファイルの列挙
- `Generated with` のような定型句

箇条書きは使ってよい。1項目が1行として数えられる。

## 作成の手順

### 1. 変更の把握

`git log` と `git diff` でコミット済みの変更を見る。未コミットの変更が残っていればユーザーに確認する。

### 2. push

ブランチをpushする。

```bash
git push -u origin <branch>
```

### 3. bodyの作成

やったことを3行以内で一時ファイルに書く。Writeで書く。

### 4. 作成

```bash
~/.claude/scripts/gh/pr-body.sh --title <title> --body-file <path> --base main
```

- `--title` は英語のconventional commit形式で書く
- `--body` は使えない。bodyは必ず `--body-file` で渡す
- `--draft` などの残りの引数は `gh pr create` にそのまま渡る

## 編集の手順

既存PRのbodyを直すときは `--edit` を付ける。

```bash
~/.claude/scripts/gh/pr-body.sh --edit --body-file <path> [<PR番号>]
```

- PR番号を省略すると現在のブランチのPRが対象になる
- `--title` は省略できる。省略すると今のtitleが残る
- bodyの条件と拒否されたときの対応は作成と同じ
- titleやラベルだけを変えるなら `gh pr edit` を直接実行してよい

## 拒否されたときの対応

スクリプトはbodyの行数を見たあと、readable-writingの `review.sh` にかける。

- 行数超過で拒否された場合
    - bodyを3行以内に削ってから再実行する
- findingsで拒否された場合
    - stderrのJSONの `problem` と `fix` を読み、bodyを直してから再実行する
    - 1パス目は `mechanical` と `llm` の両方が拒否条件になる
    - 2パス目以降は `mechanical` のみが拒否条件になり、`llm` のfindingsはstderrに出るが通る

再実行は同じコマンドをそのまま実行する。パス数はブランチごとに数える。

## 注意

- `review.sh` は `claude -p` を7並列で起動するので、1回の実行に時間がかかる
