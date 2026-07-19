---
name: pr-review
description: Review a GitHub pull request from multiple perspectives in parallel, output only findings, then let the user pick which to fix in the same session. Use when the user asks to review a PR by number, mentions "PRレビュー" / "PR review" with a number, or invokes `/pr-review <number>`. Fans out subagents for absolute-rules, stop-slop, security, architecture, code-quality, testing, and ai-antipattern.
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr list:*), Bash(gh pr checkout:*), Bash(gh api:*), Bash(git log:*), Bash(git status:*), Bash(git diff:*), Bash(git checkout:*), Bash(git fetch:*), Bash(git add:*), Bash(git push:*), Bash(git worktree:*), Bash(nix develop -c git commit:*), Bash(docker build:*), Read, Edit, Write, Glob, Grep, Agent
---

# PR Review

引数として渡されたPR番号のコードレビューを、複数観点のサブエージェントに並列実行させ、結果を統合して**指摘のみ**を出力する。良い点や要約は出力しない。出力後、どの指摘に対応するかをユーザーにチェックボックスで選ばせ、選ばれたものを同じセッションで修正する。

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

- PRタイトルと本文
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
- 各指摘に **通し番号** (`F1`, `F2`, ...) を付ける。以降の選択と修正フェーズでこの番号を使う。
- 各指摘に対して **対応要否の所見** を付ける。「対応すべき」「対応不要」「判断保留」のいずれかと、その理由と対応方針を1-2文で書く。必要なら該当ファイルをReadで開いて現状を確認してから判断する。所見はレビュアーの指摘を鵜呑みにせず、自分で妥当性を検証した結果を書く。

### 4. 出力フォーマット

Markdownで以下の形式で出力する。指摘が0件なら「指摘なし」とだけ書き、そのまま終了する (以降のフェーズには進まない)。前置きは書かない。

```markdown
## REJECT

### F1. <file>:<line> [観点1, 観点2]
**問題**: <problem>
**修正**: <fix>
**カテゴリ**: <category>
**所見**: <対応すべき/対応不要/判断保留: 理由と対応方針>

<以降同様>

## Warning

<以降同様>
```

REJECTが1件でもあれば末尾に `判定: REJECT` を追記する。すべてWarningのみなら `判定: Warning`、指摘なしなら `判定: APPROVE`。

### 5. 対応する指摘の選択

ステップ4の出力 (所見付き) を提示したあと、`AskUserQuestion` を **multiSelect: true** で呼び出し、対応する指摘をユーザーに選ばせる。

- 1問あたり `options` は最大4件、1回の呼び出しで `questions` は最大4問。つまり最大16件まで1画面に並べられる。
- findings をseverity順に4件ずつのグループに分割し、各グループを1問として並べる (`question`: 「グループ1: 対応する指摘を選択してください」など)。`header` は「対応対象」で統一。
- 各 option の `label` は `F<番号>: <file>:<line>`、`description` に `[severity][所見: 対応すべき/不要/保留] <problem の要約>` を入れる。
- 所見が「対応すべき」の指摘を推奨としてグループ内の先頭に置く。
- findings が16件を超える場合は、まず severity=REJECT のみを対象に AskUserQuestion し、REJECT対応後にWarning用の AskUserQuestion をもう一度出す。

ユーザーが1件も選ばなければ「対応対象なし」と1行だけ返して終了する。

### 6. PRブランチの準備

- `git worktree list` で対象PRのブランチ用worktreeが既にあれば、そこで作業する (cd はせず、絶対パスで指定する)。
- なければ `gh pr checkout <PR番号>` でPRのブランチに切り替える。切り替え前に `git status` で未コミットの変更がないことを確認する。あれば、その旨をユーザーに伝えて停止する。

### 7. 選択された指摘の修正

選ばれた各 finding について次を行う。findings は独立とは限らないため、同一ファイルへの変更は順番に、依存があれば依存順に処理する。

- finding の内容と対象ファイル/行を確認する。必要ならファイルを Read で開き、diff との整合を取る。
- **潜在的なバグ (severity: REJECT の security / code-quality / testing カテゴリなど) の場合**: まず落ちるテストを書いてテストが失敗することを確認してから修正する (t-wada TDD Style)。
- **それ以外の場合**: 直接コードを修正する。
- テストがあるプロジェクトではテストを実行する (Go の場合は `docker build --target test runner/`)。テスト実行手段がない場合はその旨を明示する。

### 8. コミットとプッシュ

- `git status` と `git diff` で意図した変更のみが含まれているか確認する。
- `git add` で対象ファイルを指定して stage する (`-A` や `.` は使わない)。
- `nix develop -c git commit` でコミットする。メッセージは conventional commit (英語) で、対応した finding 番号を本文に列挙する。
- 追加のプッシュは **ユーザーに確認してから** 行う。無確認では push しない。

### 9. まとめの出力

対応済みと未対応の finding を番号順に列挙する。

```markdown
## 対応済み
- F1: <one-line summary>
- F3: <one-line summary>

## 未対応
- F2: <理由 or 「ユーザー選択外」>
```

## 注意

- `severity` の判定はポリシーファイルの表に従わせる。統合時にサブエージェントの判断を上書きしない。
- ポリシー本文が日本語なので、指摘も日本語で書く。
- 変更ファイル外の既存問題はWarning扱いにする。
- diffに登場しない行の推測指摘は禁止する。ファクトチェックが必要な場合は該当ファイルをReadで開いてから指摘する。
- 修正フェーズでは、指摘に書かれた `fix` を **そのまま実装しない**。ファイルの現状を Read してから、現状に合う最小の変更を実装する。
- 「対応不要」と判断した finding があれば、まとめの「未対応」欄にその理由を1行で書く。
