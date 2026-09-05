# 文書構成

## 検出対象

### 命題型の見出し

見出しが主張になっている。本文冒頭でその主張を言い換えて繰り返す形も含む。

#### AI版

```
## キャッシュを挟むと初回ビルドが3倍速くなる

キャッシュを挟めば初回ビルドは大幅に短縮できる。計測すると9分が3分になった。

## Caching makes the first build three times faster

Caching cuts the first build down a lot. We measured it: nine minutes became three.
```

#### 修正版

```
## ビルドキャッシュ

初回ビルドは9分から3分になった。

## Build cache

The first build went from nine minutes to three.
```

#### 修正の型

- 見出しを名詞句にする
    - テーマの名前を置く
- 本文は具体例から入る

### 見出しと中身のずれ

見出しを立てたあと、手元にある材料でそこを埋める形。

- 「背景」(Background)の下に仕様を並べる
- 「課題」(Problem)の下に解決策を並べる
- 「概要」(Overview)の下に詳細を並べる

#### AI版

```
## 目的

`actions/cache` を `.github/workflows/ci.yml` に追加し、`node_modules` と `.next/cache` をキーに含める。

## Purpose

Add `actions/cache` to `.github/workflows/ci.yml`, keyed on `node_modules` and `.next/cache`.
```

```
## 目的

CIにキャッシュを入れる。

## 構成

`actions/cache` を `.github/workflows/ci.yml` に追加する。

## Purpose

Add caching to CI.

## Layout

Add `actions/cache` to `.github/workflows/ci.yml`.
```

#### 修正版

```
## 目的

初回ビルドの9分を短くする。1日6回回していて、待ち時間が54分ある。

## Purpose

Cut the nine-minute first build. We run it six times a day, so that's fifty-four minutes of waiting.
```

```
## 構成

`actions/cache` を `.github/workflows/ci.yml` に追加する。

## Layout

Add `actions/cache` to `.github/workflows/ci.yml`.
```

#### 修正の型

書き手がその見出しに置く中身を持っているか確かめる。

- 持っている
    - 見出しに書いたことを本文に置く
- 持っていない
    - 節ごと消す
- 見出しの語とずれた中身を持っている
    - 見出しのほうを中身に合わせて変える

`目的` `背景` `課題` の下にやることの言い換えがある場合、書き手は理由を持っていない。見出しを付け替えず、節ごと消す。

書き手が知らないことは書かない。埋めた理由を、読み手は書き手の判断として読む。

### しないことの記述

書き手がやらなかったこと、読み手に取らせない選択肢を本文に残す形。読み手がまだ聞いていないことに先回りして答えている。

- 節の見出し
    - 「対象外」
    - 「スコープ外」
    - 「Non-goals」
    - 「本ドキュメントでは扱わない」
- 本文の記述
    - 構成の説明で使っていないものを挙げる
    - 採らない案を段落で説明する

#### AI版

```
## 対象
- 技術文書
- README

## 対象外
- 体験記
- 感想

## In scope
- Technical docs
- READMEs

## Out of scope
- Trip reports
- Opinion pieces
```

```
LambdaはENIにEIPを関連付けて外向き通信を確保している。NAT Gatewayは使っていない。

Lambda reaches the internet through an EIP on its ENI. We don't use a NAT gateway.
```

#### 修正版

```
## 対象
- 技術文書
- README

## In scope
- Technical docs
- READMEs
```

```
LambdaはENIにEIPを関連付けて外向き通信を確保している。

Lambda reaches the internet through an EIP on its ENI.
```

#### 修正の型

否定で書いた文を集めて、次で分ける。

- 肯定形で同じことが言える
    - 肯定形で書く
- 読み手がまだ聞いていない選択肢を否定している
    - 消す
- 原因を絞る根拠になる事実の不在
    - 残す
    - 「`DisassociateAddress`の記録がない」
- 原因が判明したあとに残る調査の記述
    - 消す
- 手順や判断が成立しない条件
    - 残す
    - 「現役のENIをAPIから判定できない」

### 経緯の記録

変更前の状態と、そこへ至る作業が本文に残っている。

- 編集跡
    - 変更前と変更後を並べた節
        - 「変更点」
        - 「Changes」
    - 本文に混ぜる語
        - `以前は`
        - `元は`
        - `〜に変更した`
- 過程
    - 作業の順序を書いた節
    - 試した順に並べた本文
    - 節にするもの
        - 途中で気づいたこと
        - 直した理由

#### AI版

```
## 変更点

- 2つのスキルを1つに統合した
- 常体で書くルールを足した

## 検出漏れを1件直した

英語のレビューが最初は検出しなかった。例が日本語だけだったのが原因だと見ている。日英併記にしたら検出されるようになった。

## Changes

- Merged the two skills into one
- Added the plain-form rule

## A miss I fixed

The English review didn't catch it at first. I think the Japanese-only examples were the cause. Making them bilingual fixed it.
```

#### 修正版

```
- `policies/common/`
    - 言語非依存のパターンと直し方
    - 例は日英併記

- `policies/common/`
    - Language-independent patterns and rewrites
    - Examples in both Japanese and English
```

#### 修正の型

今その文書が何であるかだけを書く。最初からその形だったものとして書き直す。

書いた過程を集めて、次で分ける。

- 編集跡の節
    - 消す
- 過程の節
    - 消す
- 過程から出た結論
    - 今の状態として書き直す
    - 上の例では日英併記が今の状態にあたる
- 今の選択を選んだ理由になる失敗
    - 選んだものを書いた文の次に1文で残す
    - 「Prismaも試したが、生成物のサイズがLambdaのデプロイ上限に当たった」

段落を箇条書きや表に組み替えても過程は残る。書いてある中身のほうを消す。

### 例外条項の後付け

ルールを書いたあと、そのルールに合わない事例に気づいて「ただし〜の場合は」を足す形。

#### AI版

```
文末は「だ」「である」で統一する。
ただし箇条書きや仕様の列挙では体言止めでよい。

Write every sentence in the active voice.
That said, passive is fine when the actor is unknown or irrelevant.
```

#### 修正版

```
常体で書く。「です」「ます」は使わない。

Name the actor in every sentence.
```

#### 修正の型

例外が要ると気づいたときは、ルール本体を書き直す。

### メタ的な構造宣言

見出しと小見出しを読めば分かることを、節の冒頭で言い直す。

#### AI版

```
## RAGの基本

RAGは検索と生成の2つのフェーズからなる。ここではまず検索フェーズを説明し、続いて生成フェーズを見ていく。

### 検索フェーズ

クエリをベクトル化し、近いチャンクを上位k件取る。

## RAG basics

RAG has two phases, retrieval and generation. This section covers retrieval first, then generation.

### Retrieval

Embed the query and take the top k nearest chunks.
```

#### 修正版

```
## RAGの基本

### 検索フェーズ

クエリをベクトル化し、近いチャンクを上位k件取る。

## RAG basics

### Retrieval

Embed the query and take the top k nearest chunks.
```

#### 修正の型

- 予告の段落を消す
- 本文には、その節でしか書けないことを書く

### 目的の言えない情報

手順書と設定の説明で、知っている事実を置ける場所に置いてしまう。書き手が、読み手に何をさせたい一文なのかを決めていない。

#### AI版

```
- 依存を入れる
    - `pnpm install`
    - 初回は3分ほどかかる

- Install dependencies
    - `pnpm install`
    - The first run takes about three minutes
```

```
`gh run list` と `gh run view` でポーリングしない。完了まで数分かかり、その間ユーザーが指示を出せなくなる。CIの結果はユーザーがGitHub上で見る。

Don't poll with `gh run list` or `gh run view`. It takes minutes, and the user can't give you anything else to do while you wait. They read CI results on GitHub anyway.
```

#### 修正版

```
- 依存を入れる
    - `pnpm install`

- Install dependencies
    - `pnpm install`
```

```
`gh run list` と `gh run view` でポーリングしない。プッシュの成否を報告して作業を終える。

Don't poll with `gh run list` or `gh run view`. Report whether the push succeeded and stop.
```

#### 修正の型

その一文を読んで読み手が何をするかを言えるか確かめる。

- 言える
    - その目的に合う文書に置く
        - 待つ間に別の作業をしてほしい
            - 手順の中に「この間に `.env` を用意しておく」と書く
        - 遅いので今後短くしたい
            - 計画の文書かissueに書く
- 言えない
    - 消す

手順に添える理由は読み手で決める。

- 読み手が人の場合
    - 理由を書く
- 読み手がAIの場合
    - 指示が絶対のとき
        - 理由を書かない
    - 判断の余地があるとき
        - 判断の材料になる事実を書く
        - 「テストが3分を超えたら分割を検討する」の3分がこれにあたる

## 検出手順

1. 見出しをすべて抜き出す
    - 名詞句になっていないものを集める
2. 見出しごとに、書き手が直下の本文でその見出しの語に答えているか確かめる
    - 優先して見る見出し
        - `目的`
        - `背景`
        - `課題`
        - `概要`
3. しないことの記述を集める
    - 探す見出し
        - `対象外`
        - `スコープ外`
        - `Non-goals`
        - `扱わない`
    - 否定で終わる文を集める
        - `〜しない`
        - `〜ではない`
        - `〜できない`
        - `〜していない`
        - `〜を使っていない`
        - `〜は採らない`
    - 名前の重なる別のものを打ち消す文を集める
        - `〜は別物`
        - `〜とは無関係`
    - 集めた文を、しないことの記述の区分で分ける
4. 経緯の記録を集める
    - 探す語
        - `変更点`
        - `以前は`
        - `元は`
        - `〜に変更した`
        - `〜を試した`
        - `〜で確かめた`
        - `〜と比べた`
    - 集めた箇所に変更前の状態があるか確かめる
    - 選んだものを書いた文の次にあるものは残す
    - 動詞で終わる見出しを集める
    - 作業の順序を書いた節を集める
5. 例外条項を探す
    - 探す語
        - `ただし`
        - `なお、〜の場合は`
    - 直前がルールの記述か確かめる
6. 各節の冒頭段落を集める
    - 構造の予告になっていないか確かめる
7. 手順書と設定の説明を集める
    - 書き手が実行に関係しない一文を挟んでいないか確かめる
    - 手順の前後にある、その手順を取る理由の説明を集める
        - できない方法の記述もこれにあたる
        - 失敗する手順の記述もこれにあたる
