---
name: pr-create
description: GitHubのPull Requestを作る。ユーザーが「PRを作る」「PR出して」と言ったとき、`/pr-create` で呼ばれたとき、または `gh pr create` がhookにブロックされたときに使う。Creates a GitHub pull request with a three-line body.
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(git push:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh repo view:*), Bash($HOME/.claude/scripts/gh/pr-create.sh:*), Read, Write
---

# PR Create

`gh pr create` と `gh pr edit --body` はhookがブロックする。PRは `~/.claude/scripts/gh/pr-create.sh` 経由でのみ作れる。

## PR bodyの条件

やったことを3行以内で書く。空行は数えない。

次は書かない。

- 理由
- 見出し
- 動作確認
- 変更ファイルの列挙
- `Generated with` のような定型句

箇条書きは使ってよい。1項目が1行として数えられる。

## 手順

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
~/.claude/scripts/gh/pr-create.sh --title <title> --body-file <path> --base main
```

- `--title` は英語のconventional commit形式で書く
- `--body` は使えない。bodyは必ず `--body-file` で渡す
- `--draft` などの残りの引数は `gh pr create` にそのまま渡る

### 5. 拒否されたときの対応

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
- 作成後にbodyを直すときも `gh pr edit --body` は使えない。`--title` やラベルの変更は `gh pr edit` で直接できる
