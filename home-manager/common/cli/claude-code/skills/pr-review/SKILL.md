---
name: pr-review
description: Review a GitHub pull request from multiple perspectives in parallel and output only findings. Use when the user asks to review a PR by number, mentions "PRレビュー" / "PR review" with a number, or invokes `/pr-review <number>`. Fans out subagents for absolute-rules, stop-slop, security, architecture, code-quality, testing, and ai-antipattern.
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr list:*), Bash(gh api:*), Bash(git log:*), Read, Agent
---

# PR Review

引数として渡されたPR番号のコードレビューを、複数観点のサブエージェントに並列実行させ、結果を統合して**指摘のみ**を出力する。良い点や要約は出力しない。

## 引数

- `$1`: PR番号 (必須)。渡されない場合はユーザーに確認する。

## 手順

### 1. PR情報の収集

以下を並列で取得する。

```bash
gh pr view <PR番号> --json number,title,body,headRefName,baseRefName,author,files,additions,deletions
gh pr diff <PR番号>
```

diffが大きい場合でも切り詰めない。全diffをレビュー対象にする。

### 2. 並列レビューの実行

Agentツールを **同一メッセージ内で7個並列に** 呼び出す。各サブエージェントに以下を渡す。

- PRタイトル・本文
- 完全なdiff
- 担当観点とポリシーファイルの絶対パス
- 出力フォーマット指定

サブエージェントの `subagent_type` は `general-purpose` を使う。

#### 観点とポリシーファイル対応表

すべて `~/.claude/skills/pr-review/policies/` 配下のファイルをReadで開かせる。

| 観点 | ポリシーファイル |
|------|-----------------|
| absolute-rules | `~/.claude/skills/pr-review/policies/absolute-rules.md` |
| stop-slop | `~/.claude/skills/pr-review/policies/stop-slop.md` |
| security | `~/.claude/skills/pr-review/policies/security.md` |
| architecture | `~/.claude/skills/pr-review/policies/architecture.md` |
| code-quality | `~/.claude/skills/pr-review/policies/code-quality.md` |
| testing | `~/.claude/skills/pr-review/policies/testing.md` |
| ai-antipattern | `~/.claude/skills/pr-review/policies/ai-antipattern.md` |

#### サブエージェントへのプロンプトテンプレート

```
あなたはPRレビュアーである。担当観点は「<観点名>」。

# 参照すべきポリシー
以下をReadで読んでから判定する。読まずに判定しない。
<ポリシーファイルの絶対パス>

# レビュー対象
## PRタイトル
<title>

## PR本文
<body>

## 差分
<full diff>

# 出力ルール
- 良い点や要約は書かない。指摘のみ。
- 各指摘は以下の形式で列挙する。指摘がなければ空の配列 `[]` だけを返す。

```json
[
  {
    "severity": "REJECT" | "Warning",
    "file": "<repo-relative path>",
    "line": <行番号または範囲 "12-18">,
    "category": "<ポリシー内の該当項目番号または節名>",
    "problem": "<何が問題か1-2文>",
    "fix": "<どう直すか1-2文>"
  }
]
```

- ファイル・行番号はdiffから実在する箇所を必ず示す。曖昧な指摘は禁止。
- 推測ではなく、diffの実コードで確認できた事実だけを指摘する。
- 担当観点の外の問題は指摘しない。
- 3件以上の同種指摘は代表1件にまとめて他該当行を列挙する。
```

### 3. 結果の統合

7つのサブエージェントから返ったfindingsをマージする。

- 同一 (file, line, problem) の重複は1件に統合する。統合時は `perspectives` に元の観点名を列挙する。
- 重複していない場合も、どの観点から出た指摘かをタグ付けする。
- 並び順はseverity (REJECT → Warning) → ファイルパス昇順 → 行番号昇順。

### 4. 出力フォーマット

Markdownで以下の形式で出力する。指摘が0件なら「指摘なし」とだけ書く。前置きは書かない。

```markdown
## REJECT

### <file>:<line> [観点1, 観点2]
**問題**: <problem>
**修正**: <fix>
**カテゴリ**: <category>

<以降同様>

## Warning

<以降同様>
```

REJECTが1件でもあれば末尾に `判定: REJECT` を追記する。すべてWarningのみなら `判定: Warning`、指摘なしなら `判定: APPROVE`。

## 注意

- `severity` の判定はポリシーファイルの表に従わせる。上記統合時にサブエージェントの判断を上書きしない。
- ポリシー本文が日本語なので、指摘も日本語で書く。
- 変更ファイル外の既存問題はWarning扱いにする。
- diffに登場しない行の推測指摘は禁止する。ファクトチェックが必要な場合は該当ファイルをReadで開いてから指摘する。
