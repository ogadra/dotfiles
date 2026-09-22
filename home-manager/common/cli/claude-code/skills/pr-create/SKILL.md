---
name: pr-create
description: PRを作る、または既存PRのbodyを直す。ユーザーが「PRを作る」「PR出して」「PRのbodyを直して」と言ったとき、ユーザーが `/pr-create` と打ったとき、または `gh pr create` や `gh pr edit --body` がhookにブロックされたときに使う。Creates or edits a pull request with a three-line body.
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(git push:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh repo view:*), Bash($HOME/.claude/scripts/gh/pr-body.sh:*), Read, Write
---

# PR Create

PRの作成とbodyの変更は `~/.claude/scripts/gh/pr-body.sh` から実行する。

## PR bodyの条件

やったことを書く。

- 行数
    - 3行以内
    - 空行
        - 数えない
    - 箇条書き
        - 1項目を1行と数える

次は書かない。

- 理由
- 見出し
- 動作確認
- 変更ファイルの列挙
- 定型句
    - `Generated with`

## 作成の手順

### 1. 変更の把握

`git log` と `git diff` でコミット済みの変更を見る。未コミットの変更が残っていればユーザーに確認する。

### 2. push

```bash
git push -u origin <branch>
```

### 3. bodyの作成

Writeで一時ファイルにbodyを書く。

### 4. 作成

```bash
~/.claude/scripts/gh/pr-body.sh --title <title> --body-file <path> --base main
```

スクリプトが終わるまで待つ。

- `--title`
    - 英語のconventional commit形式で書く
- body
    - `--body-file` でだけ渡せる
- `--draft` などの残りの引数
    - `gh pr create` にそのまま渡す

## 編集の手順

`--edit` を付ける。

```bash
~/.claude/scripts/gh/pr-body.sh --edit --body-file <path> [<PR番号>]
```

- PR番号を省略した場合
    - 現在のブランチのPRを対象にする
- `--title`
    - 編集では省略できる
- `gh pr edit` を直接実行してよいもの
    - title
    - ラベル

## スクリプトが拒否したときの対応

- 行数超過
    - bodyを3行以内に削る
- findings
    - stderrのJSONを読む
        - `problem`
        - `fix`
    - bodyを直す

直したら同じコマンドをそのまま実行する。

- パス数
    - ブランチごとに数える
- 拒否条件
    - `mechanical`
        - 毎回
    - `llm`
        - 1パス目だけ
