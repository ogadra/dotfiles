# 文書構成

## パターン

### 命題型の見出し

見出しの主張を本文冒頭で言い換えて繰り返す形も含む。

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

### 見出しから言い当てられる本文

見出しの言い換えと、見出しだけ読んだ読み手が言い当てられることが入る。

#### AI版

```
リトライ間隔を指数バックオフにする

失敗するたびに次の待ち時間が伸びる。

Switch the retry interval to exponential backoff

Each failure makes the next wait longer.
```

#### 修正版

```
リトライ間隔を指数バックオフにする

Switch the retry interval to exponential backoff
```

#### 修正の型

見出しだけ読んだ読み手が本文の各文を言い当てられるか確かめる。

- 言い当てられる
    - 消す
- 言い当てた内容と逆のことが起きる
    - 残す
- 見出しの語からは届かない
    - 残す

消した結果、本文が空になったら見出しだけを置く。

### 見出しと本文のずれ

見出しを立てたあと、手元にある中身でそこを埋める。

- 「背景」の下に仕様を並べる
- 「課題」の下に解決策を並べる
- 「概要」の下に詳細を並べる

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

その見出しに置く中身を持っているか確かめる。

- 持っている
    - 見出しに書いたことを中身として置く
- 持っていない
    - 節ごと消す
    - 次の見出しの下にやることの言い換えがあるものがこれにあたる
        - `目的`
        - `背景`
        - `課題`
- 見出しの語とずれた中身を持っている
    - 見出しのほうを中身に合わせて変える

### しないことの記述

やらなかったこと、読み手に取らせない選択肢を本文に残している。書き手が読み手のまだ聞いていないことに先回りして答えている。

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

- 肯定形で同じことが言える場合
    - 肯定形で書く
- 読み手がまだ聞いていない選択肢を否定している場合
    - 消す
- 原因を絞る根拠として、事実が無いことを書いている場合
    - 残す
    - 「`DisassociateAddress`の記録がない」
- 原因が判明したあとに、調査の過程を書いている場合
    - 消す
- 手順や判断が成立しない条件を書いている場合
    - 残す
    - 「現役のENIをAPIから判定できない」

### 経緯の記録

書き手が変更前の状態と、そこへ至る作業を本文に残している。

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

編集跡と過程を集めて、次で分ける。

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

### 例外の後付け

ルールを書いたあと、そのルールに合わない事例に気づいて「ただし〜の場合は」を足してしまう。

#### AI版

```
文末は「だ」「である」で統一する。
ただし箇条書きや仕様の列挙では体言止めでよい。

Write every sentence in the active voice.
That said, passive is fine when the actor is unknown or irrelevant.
```

#### 修正版

```
常体で書く。体言止めもこれに入る。

Name the actor in every sentence.
```

#### 修正の型

例外が要ると気づいたときは、ルール本体を書き直す。

### メタ的な構造宣言

見出しと小見出しを読めば分かることを節の冒頭で言い直す。

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
- 本文にはその節でしか書けないことを書く

### 目的の言えない情報

手順書と設定の説明で、知っている事実を置ける場所に置いてしまう。読み手に何をさせたい一文なのかを決めていない。

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

### 本文を繰り返すまとめ

本文で言い終えたことを文書の最後でもう一度並べる。

- 節の見出し
    - 「まとめ」
    - 「おわりに」
    - 「Summary」
- 段落の書き出し
    - `まとめると、`
    - `要するに、`
    - `In summary,`

#### AI版

```
## 原因

`package-lock.json` のハッシュがキーに入っていなかった。

## 対応

キーにハッシュを足し、初回ビルドが9分から3分になった。

## まとめ

キャッシュのキーを見直したことで、ビルドが速くなった。

## Cause

The cache key left out the hash of `package-lock.json`.

## Fix

Adding the hash to the key took the first build from nine minutes to three.

## Summary

Revisiting the cache key made the build faster.
```

#### 修正版

```
## 原因

`package-lock.json` のハッシュがキーに入っていなかった。

## 対応

キーにハッシュを足し、初回ビルドが9分から3分になった。

## Cause

The cache key left out the hash of `package-lock.json`.

## Fix

Adding the hash to the key took the first build from nine minutes to three.
```

#### 修正の型

- 本文に無い情報がまとめに無い場合
    - まとめを消す
- 本文に無い数値や条件がまとめにある場合
    - 本文の該当する節へ移してから、まとめを消す
- 本文に無い結論がまとめにある場合
    - 残す

### 本文に残った書き方の指示

書き手がAIに出した指示や、書くときに決めた方針が本文に残っている。

- 口調や使う語の宣言
- 扱う範囲を絞ったことの宣言

#### AI版

```
今回は専門用語をできるだけ使わずに、変更の要点に絞って説明します。

I'll keep this jargon-free and stick to the key points of the change.
```

#### 修正版

```
ログイン画面でパスワードを3回間違えると、10分ロックするようにした。

The login screen now locks for ten minutes after three wrong passwords.
```

#### 修正の型

- 書き方を宣言する文の場合
    - 消す
    - 宣言のあとの本文から書き始める
- 読み手のために範囲や前提を示す文の場合
    - 残す
    - `この手順は macOS だけを対象にする`

## 検出手順

1. 見出しをすべて抜き出す
    - 名詞句になっていないものを集める
2. 見出しごとに直下の本文と見出しの語を突き合わせる
    - 優先して見る見出し
        - `目的`
        - `背景`
        - `課題`
        - `概要`
3. 見出しだけ読んだ読み手が本文の各文を言い当てられるか確かめる
    - 見出しが動詞で始まる場合
        - その動作に伴う結果を本文に書いていないか確かめる
4. しないことの記述を集める
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
    - 書き手が同名の別物を打ち消す文を集める
        - `〜は別物`
        - `〜とは無関係`
    - しないことの記述にある修正の型で集めた文を分ける
5. 経緯の記録を集める
    - 探す語
        - `変更点`
        - `以前は`
        - `元は`
        - `〜に変更した`
        - `〜を試した`
        - `〜で確かめた`
        - `〜と比べた`
    - 動詞で終わる見出しを集める
    - 作業の順序を書いた節を集める
    - 集めた箇所に変更前の状態があるか確かめる
6. 例外の後付けを探す
    - 探す語
        - `ただし`
        - `なお、〜の場合は`
    - 直前がルールの記述か確かめる
7. 各節の冒頭段落を集める
    - 構造の予告になっていないか確かめる
8. 手順書と設定の説明を集める
    - 実行に関係しない一文を挟んでいないか確かめる
    - 手順の前後にある、その手順を取る理由の説明を集める
        - できない方法の記述もこれにあたる
        - 失敗する手順の記述もこれにあたる
9. 文書の最後の節と段落を集める
    - 本文に無い情報があるか確かめる
10. 書く行為を述べる文を集める
    - 探す語
        - `説明します`
        - `紹介します`
        - `まとめます`
        - `I'll`
    - 口調や範囲の決め方を宣言していないか確かめる
