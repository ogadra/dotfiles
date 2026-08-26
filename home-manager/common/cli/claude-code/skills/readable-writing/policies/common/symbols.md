# 記号

記号と字面を見る。多くは検索して全置換で潰せる。

## 検出対象

### 本文中の強調

地の文の一部を `**` で太字にする形。

#### AI版

```
SEO対策には**次の施策を使う。**

To rank higher **you need the following.**
```

#### 修正版

```
SEO対策には次の施策を使う。

To rank higher you need the following.
```

#### 修正の型

太字を消す。

### 装飾絵文字

`🚀🎯✨💡🔥📈` のような装飾絵文字が、段落末や箇条書きに等間隔で出てくる形。

#### AI版

```
## セットアップ 🚀

- 依存を入れる ✨
- 環境変数を設定する 💡
- DBを初期化する 🎯

## Setup 🚀

- Install dependencies ✨
- Set the environment 💡
- Initialize the database 🎯
```

#### 修正版

```
## セットアップ

- 依存を入れる
- 環境変数を設定する
- DBを初期化する

## Setup

- Install dependencies
- Set the environment
- Initialize the database
```

#### 修正の型

消す。

### 括弧による後置補足

補足や例示を括弧に押し込む形。括弧の中身が本題なのか脇道なのか判断できないまま読み進めることになる。

#### AI版

```
- 二項対比(「Aではなく、Bだ」)を多用していないか?
- 見出しが「主張」になっていないか?(命題型の見出し)

- Any binary contrasts ("not X, it's Y")?
- Does the heading make a claim? (propositional heading)
```

#### 修正版

```
- 二項対比を多用していないか?
    - `Aではなく、Bだ`
- 見出しが「主張」になっていないか?

- Any binary contrasts?
    - `not X, it's Y`
- Does the heading make a claim?
```

#### 修正の型

語を同定するときにだけ括弧を使う。原語の併記と、略語の初出での展開がこれにあたる。

- 原語の併記
    - `否定的列挙 (negative listing)`
- 略語の初出での展開
    - `RAG (Retrieval-Augmented Generation)`

それ以外の括弧は、中身が読み手に必要なら本文か1段下の階層に置き、必要でないなら消す。

### 文中での改行

1行の文字数を意識して、文の途中で改行を入れる形。

#### AI版

```
リトライは指数バックオフで最大3回まで。3回を超えた場合はDLQに送り、
アラートを飛ばす。

Retries use exponential backoff, up to three times. Past three, the message
goes to the DLQ and the alert fires.
```

#### 修正版

```
リトライは指数バックオフで最大3回まで。3回を超えた場合はDLQに送り、アラートを飛ばす。

Retries use exponential backoff, up to three times. Past three, the message goes to the DLQ and the alert fires.
```

#### 修正の型

改行は文の終わりか段落の切れ目にだけ入れる。1行が長くなることは気にしない。

## 検出手順

1. `**` を検索する。
2. 絵文字を検索する。
3. `(` `(` を検索し、中身が原語併記と略語の展開でないものを集める。
4. 各行の末尾を見て、文の終わりで終わらず次の行に文が続くものを集める。
