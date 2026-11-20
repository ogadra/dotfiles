# 箇条書き

指摘は文書に残す内容にだけ出す。

## 検出対象

### 平坦な箇条書き

理由や補足を持つ項目を第1階層に同じ深さと長さで並べている。項目名とその説明を `**項目名**: 説明` の形で1行に押し込んでいる。

#### AI版

```
- **長さのムラ**: 段落と文の長さをバラバラにする。1行で終わる段落と10行続く段落を混ぜる。
- **密度のムラ**: 興味のある話題には固有名詞・数値・事実を詰め、興味のないところは短く書く。

- **Varied length**: Mix paragraph and sentence lengths. Put a one-line paragraph next to a ten-line one.
- **Varied density**: Pack names and numbers into what you care about, skim the rest.
```

#### 修正版

```
- 長さのムラ
    - 段落と文の長さをバラバラにする
    - 1行で終わる段落と10行続く段落を混ぜる
- 密度のムラ
    - 興味のある話題には固有名詞や数値を詰める
    - 興味のないところは短く書く

- Varied length
    - Mix paragraph and sentence lengths
    - Put a one-line paragraph next to a ten-line one
- Varied density
    - Pack names and numbers into what you care about
    - Skim the rest
```

#### 修正の型

1行に1つのことだけ書き、階層で主従を示す。

| 置くもの | 階層 |
|---|---|
| 項目名 | 第1階層 |
| 理由 | 1段下 |
| 補足 | 1段下 |
| 具体例 | 1段下 |
| 言い換え | 1段下 |

### 1項目に詰め込んだ並列

箇条書きの1項目に読点やカンマで複数の語が並ぶ。読み手はその行を読んだだけでは並列なのか補足なのかを決められない。

#### AI版

```
- 対応ブラウザはChrome、Firefox、Safariの最新2バージョン
- APIは200、404、500を返す

- Supported browsers are the latest two versions of Chrome, Firefox, and Safari
- The API returns 200, 404, and 500
```

#### 修正版

```
- 対応ブラウザ
    - Chrome
    - Firefox
    - Safari
    - いずれも最新2バージョン
- APIが返すステータス
    - `200`
    - `404`
    - `500`

- Supported browsers
    - Chrome
    - Firefox
    - Safari
    - Latest two versions of each
- Status codes the API returns
    - `200`
    - `404`
    - `500`
```

#### 修正の型

1項目には1つだけ書く。

- 分けた項目に共通の見出しが付く場合
    - 項目名を第1階層に置く
    - 値を1段下げる
- 全項目にかかる条件がある場合
    - 並列の1項目として置く

### 条件と処置の同居

1項目に `XならY` が収まっている。条件と処置は別のことなので、読み手は他の項目の条件と突き合わせる前に、1行の中で2つを分解することになる。分岐が3つ並ぶと目で追えなくなる。

#### AI版

```
- 節の区切りなら見出しにする
- 直前の文の一部なら、その文に畳む
- どちらでもないなら消す

- If it breaks a section, make it a heading
- If it belongs to the sentence before it, fold it in
- If neither, delete it
```

#### 修正版

```
- 節の区切りの場合
    - 見出しにする
- 直前の文の一部の場合
    - その文に畳む
- どちらでもない場合
    - 消す

- It breaks a section
    - Make it a heading
- It belongs to the sentence before it
    - Fold it in
- Neither
    - Delete it
```

#### 修正の型

| 置くもの | 階層 |
|---|---|
| 条件 | 第1階層 |
| 処置 | 1段下 |

### 値と項目名を入れ替えた階層

値が第1階層にあり、項目名が1段下がっている。

#### AI版

```
- 3回まで再送する
    - リトライの回数

- Retry up to three times
    - Retry count
```

#### 修正版

```
- リトライの回数
    - 3回まで

- Retry count
    - Up to three
```

#### 修正の型

| 置くもの | 階層 |
|---|---|
| その項目が何についての項目かを名指す語 | 第1階層 |
| `XならY` の `X` のような、分岐を作る条件 | 第1階層 |
| 値 | 1段下 |
| 根拠 | 1段下 |
| 例 | 1段下 |
| 適用範囲を狭めるだけの条件 | 1段下 |

### 地の文に書き連ねた並列

並列の項目に `第一に` のような数え上げの接続語を付けて、地の文の段落に書き連ねる。

#### AI版

```
第一に、責任の所在を明確にすることが重要だ。第二に、定期的なレビューを実施する必要がある。第三に、ナレッジ共有の仕組みを作るとよい。

First, make ownership explicit. Second, review on a schedule. Third, build a way to share what people know.
```

#### 修正版

```
1. 責任の所在を明確にする
2. 定期的にレビューをする
3. 知識を共有する仕組みを作る

1. Make ownership explicit
2. Review on a schedule
3. Share what people know
```

#### 修正の型

- 順序に意味が無い場合
    - 箇条書きにする
- 順序に意味がある場合
    - 番号付きの箇条書きにする

### 形のそろわない並列

名詞で終わる項目と動詞で終わる項目を同じ階層に混ぜて並べる。

#### AI版

```
- キャッシュの導入
- テストを並列で回す
- ログの出力先が変わった

- Cache introduction
- Run tests in parallel
- The log destination changed
```

#### 修正版

```
- キャッシュを入れる
- テストを並列で回す
- ログの出力先を変える

- Add a cache
- Run tests in parallel
- Change the log destination
```

#### 修正の型

- 並べた項目を同じ形にそろえる
    - 手順と変更点
        - 動詞の形
    - 項目名
        - 名詞の形

## 検出手順

1. 並列を1行に詰め込んだ項目を集める
    - 探す記号や語
        - 読点
        - カンマ
        - `と`
        - `および`
        - `and`
    - 並列を1行に詰めていないか確かめる
2. 次の語を含む箇条書きの項目を集める
    - 探す語
        - `なら`
        - `場合は`
        - `if`
    - 1項目に条件と処置の両方を書いていないか確かめる
3. 第1階層の項目を集める
    - 理由や補足が第1階層に紛れていないか確かめる
4. 数え上げの接続語を探す
    - 探す語
        - `第一に`
        - `第二に`
        - `第三に`
        - `First,`
        - `Second,`
        - `Third,`
    - 段落が並列の項目になっていないか確かめる
5. 第1階層と子項目を突き合わせる
    - 第1階層に値や条件を置き、項目名を1段下げていないか確かめる
6. 同じ階層に並んだ項目の終わり方を並べる
    - 名詞で終わる項目と動詞で終わる項目が混ざっていないか確かめる

## 平坦な箇条書きと詰め込みが同時に出る例

READMEのセットアップ節。

#### AI版

```
## セットアップ

**前提**: Node.js 20以上、pnpm 9以上が必要です。

- **依存の導入**: `pnpm install` を実行します(初回は3分ほどかかります)。
- **環境変数**: `.env.example` をコピーして `.env` を作り、DATABASE_URL、REDIS_URL、S3_BUCKET を埋めます。
- **DBの初期化**: `pnpm db:migrate` を実行します(Dockerが起動している必要があります)。

## Setup

**Requirements**: Node.js 20 or later, pnpm 9 or later.

- **Install dependencies**: Run `pnpm install` (the first run takes about three minutes).
- **Environment**: Copy `.env.example` to `.env` and fill in DATABASE_URL, REDIS_URL, S3_BUCKET.
- **Database**: Run `pnpm db:migrate` (Docker must be running).
```

#### 修正版

```
## セットアップ

### 前提

- Node.js 20以上
- pnpm 9以上
- Dockerが起動していること

### 手順

- 依存を入れる
    - `pnpm install`
- 環境変数を設定する
    - `.env.example` をコピーして `.env` を作る
    - `DATABASE_URL`
    - `REDIS_URL`
    - `S3_BUCKET`
- DBを初期化する
    - `pnpm db:migrate`

## Setup

### Requirements

- Node.js 20 or later
- pnpm 9 or later
- Docker running

### Steps

- Install dependencies
    - `pnpm install`
- Set the environment
    - Copy `.env.example` to `.env`
    - `DATABASE_URL`
    - `REDIS_URL`
    - `S3_BUCKET`
- Initialize the database
    - `pnpm db:migrate`
```

#### 修正の型

| 元の書き方 | 直し方 |
|---|---|
| 太字のラベル | 見出しにする |
| 前提と手順 | 節に分ける |
| 手順の説明とコマンド | 1段下げる |
| 環境変数 | 1項目に1つ置く |
| 括弧の前提条件 | 前提の節に移す |
| 実行に関係しない括弧の補足 | 消す |
