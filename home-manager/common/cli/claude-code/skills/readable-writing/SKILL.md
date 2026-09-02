---
name: readable-writing
description: AIが書いた文章特有の読みにくさを、7観点の `claude -p` を並列で走らせてレビューし、出た指摘をすべて修正する。Reviews prose for AI writing patterns and rewrites it.
allowed-tools: Bash(bash ~/.claude/skills/readable-writing/scripts/review.sh:*), Bash(mktemp:*), Read, Edit, Write, Glob, Grep, AskUserQuestion
metadata:
  trigger: 技術文書、README、コミットメッセージ、PR説明、コード内コメント、実装計画書、設計書等のレビューと修正
  language: ja, en
  derived-from: iKora128/stop-ai-slop-jp, hardikpandya/stop-slop
---

# Readable Writing

成果物は修正後の文章だけ。

## 対象

- 技術文書
- README
- コミットメッセージ
- PR説明
- コード内コメント
- 実装計画書
- 設計書

自然言語だけを見る。

## 手順

### 1. 対象の確定

`$1` がレビュー対象。

- ファイルパスの場合
    - そのパスを使う
- ディレクトリの場合
    - Globでファイルを集める
    - 対象をユーザーに確認する
    - ファイルごとにステップ2から繰り返す
- 会話中の下書きの場合
    - 一時ファイルに書き出す
    - そのファイルのパスを使う
- ユーザーが渡さなかった場合
    - 対象を聞く

### 2. 並列レビューの実行

`scripts/review.sh` を実行する。

```bash
bash ~/.claude/skills/readable-writing/scripts/review.sh <ファイルパス>
```

出力は次の形。

```json
[
  {
    "perspective": "立場",
    "file": "<ファイルパス>",
    "line": "12",
    "quote": "<該当箇所の原文>",
    "category": "<ポリシー内の該当節名>",
    "problem": "<何が読みにくいか1文>",
    "fix": "<書き換えた後の文そのもの、または null>"
  }
]
```

スクリプトが非ゼロで終了したら、標準エラーの内容をそのままユーザーに見せて止まる。

#### 観点とポリシーファイルの対応表

ファイルは `policies/` の下の `common/`、`ja/`、`en/` にある。

| 観点 | ファイル | 見るもの |
|---|---|---|
| 立場 | `stance.md` | 書き手が引き受ける範囲 |
| 主体 | `agency.md` | 行為の主体 |
| 箇条書き | `lists.md` | 箇条書きの階層と粒度 |
| 文書構成 | `document.md` | 見出し、節、情報の取捨 |
| 修辞 | `rhetoric.md` | 構文の型とリズム |
| 語彙 | `vocabulary.md` | 語の選択 |
| 記号 | `symbols.md` | 記号と字面 |

### 3. 結果の統合

- 重複の統合
    - 同一の `quote` を指す指摘は1件にする
- 並び順
    - ファイルパス昇順
    - 行番号昇順
- 捨てる指摘
    - `quote` が本文に実在しないもの
- 捨てない指摘
    - 言語ごとの作法と食い違うもの
    - 対象の種類ごとの通例と食い違うもの
        - gitの72桁折り返し
- ポリシーだけで決まらない場合
    - AskUserQuestionで聞く
    - 回答のとおりに直す

残った指摘はすべて直す。

### 4. 修正

- 対象ファイルをReadで開く
    - `quote` の前後を読む
- `fix` がある場合
    - 前後の文と繋がるように書き換えてから使う
- `fix` が `null` の場合
    - `problem` を読む
    - 前後の文に合う形に書き換える
- 同一段落への修正が複数ある場合
    - 段落ごとにまとめて書き換える
- 修正の順序
    1. 立場と主体の指摘を直す
    2. 箇条書き、文書構成、修辞の指摘で段落を組み直す
    3. 語彙と記号の指摘が本文に残っているか確かめる
- 書き換えるとき
    - 別の観点のポリシーに違反しないか確認する
    - 二項対比を括弧に逃がさない
- 直し方に迷った場合
    - 該当ポリシーのAI版と修正版の対比を読む
- 指摘の無い箇所は書き換えない

### 5. 成果物の提示

- ファイルが対象の場合
    - Editで書き換えて終わる
- 会話中の下書きが対象の場合
    - 修正後の本文だけを出力する

指摘が0件なら「修正なし」とだけ返す。
