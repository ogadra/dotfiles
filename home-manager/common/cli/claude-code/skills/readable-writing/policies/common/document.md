# 文書構成

## 検出対象

### 命題型の見出し

見出しが主張になっている。見出しはテーマの名前、つまり名詞句で立てる。

命題型の見出しを立てると、書き手は本文にその主張の裏付けを並べる。

見出しで主張を置き、本文冒頭で同じ主張を言い換えて繰り返す形もこれにあたる。

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

見出しを名詞句にして、本文は具体例から入る。

### 見出しと中身のずれ

見出しを立てたあと、手元にある材料でそこを埋める形。書き手は依頼者から聞いた作業内容しか持っていないので、「目的」の下に手段を並べる。読み手はなぜやるのかを探して見つけられない。

「目的」以外の見出しでも、本文が見出しの語に答えていない。

- 「背景」の下に仕様を並べる
- 「課題」の下に解決策を並べる
- 「概要」の下に詳細を並べる
- "Background"の下に仕様を並べる
- "Problem"の下に解決策を並べる
- "Overview"の下に詳細を並べる

#### AI版

```
## 目的

`actions/cache` を `.github/workflows/ci.yml` に追加し、`node_modules` と `.next/cache` をキーに含める。

## Purpose

Add `actions/cache` to `.github/workflows/ci.yml`, keyed on `node_modules` and `.next/cache`.
```

#### 修正版

```
## 目的

初回ビルドの9分を短くする。1日6回回していて、待ち時間が54分ある。

## Purpose

Cut the nine-minute first build. We run it six times a day, so that's fifty-four minutes of waiting.
```

#### 修正の型

見出しに書いたことを本文に置く。書けないなら、見出しのほうを中身に合わせて変える。

### しないことの記述

書き手がやらなかったこと、読み手に取らせない選択肢を本文に残す形。読み手がまだ聞いていないことに先回りして答えている。

- 「対象外」の節
- 「スコープ外」の節
- 「Non-goals」の節
- 「本ドキュメントでは扱わない」の節
- 構成の説明で、使っていないものを挙げる
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

否定で書かれた文を集めて、次で分ける。

| 記述 | 扱い |
|---|---|
| 肯定形で同じことが言える | 肯定形で書く |
| 読み手がまだ聞いていない選択肢を否定している | 消す |
| 調べて確認した事実の不在 | 残す |
| 手順や判断が成立しない条件 | 残す |

- 調べて確認した事実の不在
    - 「`DisassociateAddress`の記録がない」
        - CloudTrailを読んだ結果
        - 原因を絞る根拠になる
- 手順や判断が成立しない条件
    - 「現役のENIをAPIから判定できない」
        - この条件で手順が詰まる

### 経緯の記録

- 編集跡
    - 「変更点」の節
        - 足したものを並べる
        - 消したものを並べる
    - 本文に混ぜる語
        - 「以前は」
        - 「元は」
        - 「〜に変更した」
- 過程
    - 何を試して何が駄目だったかを書く
    - 途中で気づいたことを節にする
    - 直した理由を節にする

読み手が知りたいのは、今どうなっていて、なぜそうなっているか。

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

今その文書が何であるかだけを書く。最初からその形だったものとして書き直し、編集跡と過程の節は消す。

過程から出た結論が今の状態の一部なら、その部分だけを状態として書き直す。上の例では、日英併記であることが今の状態にあたる。

### 例外条項の後付け

ルールを書いたあと、そのルールに合わない事例に気づいて「ただし〜の場合は」を足す形。ルール本体を直さないまま逃げ道だけを足すので、読み手はどこまでが原則でどこからが例外なのか分からなくなる。

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

予告の段落を消す。読み手は見出しと小見出しから構造を読む。本文には、その節でしか書けないことを書く。

### 目的の言えない情報

知っている事実を、置ける場所に置く形。書いても害はないという判断で足すので、読み手に何をさせたいのかを決めていない。

#### AI版

```
- 依存を入れる
    - `pnpm install`
    - 初回は3分ほどかかる

- Install dependencies
    - `pnpm install`
    - The first run takes about three minutes
```

#### 修正版

```
- 依存を入れる
    - `pnpm install`

- Install dependencies
    - `pnpm install`
```

#### 修正の型

「初回は3分ほどかかる」で読み手に何をさせたいのかを言えるか確かめる。言えたら、その目的に合う文書に置く。

- 待つ間に別の作業をしてほしい
    - 手順の中にそう書く
        - 「この間に `.env` を用意しておく」
- 遅いので今後短くしたい
    - 計画の文書かissueに書く
- どれでもない
    - 消す

### 読み手を見ていない補足

#### AI版

```
`gh run list` と `gh run view` でポーリングしない。完了まで数分かかり、その間ユーザーが指示を出せなくなる。CIの結果はユーザーがGitHub上で見る。

Don't poll with `gh run list` or `gh run view`. It takes minutes, and the user can't give you anything else to do while you wait. They read CI results on GitHub anyway.
```

#### 修正版

```
`gh run list` と `gh run view` でポーリングしない。プッシュの成否を報告して作業を終える。

Don't poll with `gh run list` or `gh run view`. Report whether the push succeeded and stop.
```

#### 修正の型

補足を書くかどうかは、それを読んで読み手が動作を変えるかで決める。

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
2. 見出しごとに、直下の本文がその見出しの語に答えているか確かめる
    - 優先して見る見出し
        - 「目的」
        - 「背景」
        - 「課題」
        - 「概要」
3. しないことの記述を集める
    - 節の見出しを検索する
        - 「対象外」
        - 「スコープ外」
        - 「Non-goals」
        - 「扱わない」
    - 否定で終わる文を集める
        - 「〜しない」
        - 「〜ではない」
        - 「〜できない」
        - 「〜していない」
        - 「〜を使っていない」
        - 「〜は採らない」
    - 集めた文を次で分ける
        - 肯定形で同じことが言える
            - 肯定形に書き換える
        - 調べて確認した事実の不在
            - 残す
        - 手順や判断が成立しない条件
            - 残す
        - どれでもない
            - 消す
4. 経緯の記録を集める
    - 次の語を検索する
        - 「変更点」
        - 「以前は」
        - 「元は」
        - 「〜に変更した」
    - 動詞で終わる見出しを集める
    - 各節を読み、作業の順序を語っているものを集める
5. 例外条項を検索する
    - 「ただし」
    - 「なお、〜の場合は」
    - 直前がルールの記述か確かめる
6. 各節の冒頭段落を集める
    - 構造の予告になっていないか確かめる
7. 手順書と設定の説明を集める
    - 実行に関係しない一文が挟まっていないか確かめる
8. 手順の前後にある、その手順を取る理由の説明を集める
    - できない方法や失敗する手順の記述もこれにあたる
