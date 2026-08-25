# 箇条書き

箇条書きの階層と粒度を見る。Markdownの組み立て方に出るクセなので、日本語でも英語でも同じ形で出る。

## 検出する

- [平坦な箇条書き](#平坦な箇条書き)
- [1項目への詰め込み](#1項目への詰め込み)
- [条件と処置の同居](#条件と処置の同居)
- [階層の付け間違い](#階層の付け間違い)

## 平坦な箇条書き

項目名と、その理由や補足を `**項目名**: 説明` の形で1行に押し込む形。全項目を同じ深さ、同じ長さで並べるので、読み手はどれが主題でどれが根拠なのか読み取れない。

### AI版

```
- **長さのムラ**: 段落と文の長さをバラバラにする。1行で終わる段落と10行続く段落を混ぜる。
- **密度のムラ**: 興味のある話題には固有名詞・数値・事実を詰め、興味のないところはサラっと流す。

- **Varied length**: Mix paragraph and sentence lengths. Put a one-line paragraph next to a ten-line one.
- **Varied density**: Pack names and numbers into what you care about, skim the rest.
```

### 修正版

```
- 長さのムラ
    - 段落と文の長さをバラバラにする
    - 1行で終わる段落と10行続く段落を混ぜる
- 密度のムラ
    - 興味のある話題には固有名詞や数値を詰める
    - 興味のないところはサラっと流す

- Varied length
    - Mix paragraph and sentence lengths
    - Put a one-line paragraph next to a ten-line one
- Varied density
    - Pack names and numbers into what you care about
    - Skim the rest
```

### 修正の型

第1階層には項目名だけを置く。理由、補足、具体例、言い換えは1段下げる。1行に1つのことだけ書く。階層で主従を示す。

## 1項目への詰め込み

箇条書きの1項目に、読点やカンマで複数の語を並べる形。項目数が減るので書いた側は整ったと思うが、読み手はどれが並列でどれが補足なのか区別できず、1つだけ引用したいときに切り出せない。

### AI版

```
- 対応ブラウザはChrome、Firefox、Safariの最新2バージョン
- APIは200、404、500を返す

- Supported browsers are the latest two versions of Chrome, Firefox, and Safari
- The API returns 200, 404, and 500
```

### 修正版

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

### 修正の型

1項目には1つだけ書く。分けた結果が長くなって読みにくいなら、グループを作って1段下げる。全項目にかかる条件も、並列の1項目として置く。

## 平坦な箇条書きと詰め込みが同時に出る例

READMEのセットアップ節を書くとき、この2つを同時にやってしまう。

### AI版

```
## セットアップ

**前提**: Node 20以上、pnpm 9以上が必要です。

- **依存の導入**: `pnpm install` を実行します(初回は3分ほどかかります)。
- **環境変数**: `.env.example` をコピーして `.env` を作り、DATABASE_URL、REDIS_URL、S3_BUCKET を埋めます。
- **DBの初期化**: `pnpm db:migrate` を実行します(Dockerが起動している必要があります)。

## Setup

**Requirements**: Node 20 or later, pnpm 9 or later.

- **Install dependencies**: Run `pnpm install` (the first run takes about three minutes).
- **Environment**: Copy `.env.example` to `.env` and fill in DATABASE_URL, REDIS_URL, S3_BUCKET.
- **Database**: Run `pnpm db:migrate` (Docker must be running).
```

### 修正版

```
## セットアップ

### 前提

- Node 20以上
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

- Node 20 or later
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

各手順の説明とコマンドを1段下げ、環境変数を1つずつ項目にした。この例に混ざっている他のパターンは別のポリシーにある。

- 括弧に逃がした前提
    - `common/symbols.md`
- 太字の見出し代用と所要時間の扱い
    - `common/document.md`

## 条件と処置の同居

箇条書きの1項目に「XならY」を収める形。条件と処置は別のことなので、読み手は1行の中で2つを分解してから、他の項目の条件と突き合わせることになる。分岐が3つ並ぶと、どこまでが条件でどこからが処置なのか目で追えなくなる。

### AI版

```
- 節の区切りなら見出しにする
- 直前の文の一部なら、その文に畳む
- どちらでもないなら消す

- If it breaks a section, make it a heading
- If it belongs to the sentence before it, fold it in
- If neither, delete it
```

### 修正版

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

### 修正の型

条件を第1階層に置き、処置を1段下げる。条件だけを縦に読めるようになり、自分がどの分岐にいるかを先に決められる。

## 階層の付け間違い

階層は付いているが、主従が逆になっている形。

### AI版

```
- 3回まで再送する
    - リトライの回数

- Retry up to three times
    - Retry count
```

### 修正版

```
- リトライの回数
    - 3回まで

- Retry count
    - Up to three
```

### 修正の型

第1階層に置くのは、その項目が何についての項目かを示す語。値、条件、根拠、例は1段下げる。

## 検出手順

1. `- **` で始まる行を検索する
    - 該当すればすべて平坦な箇条書き
2. 第1階層の項目に次の記号や語が入っている行を集める
    - 読点
    - カンマ
    - `と`
    - `および`
    - 並列を1行に詰めていないか確かめる
3. 第1階層の項目に句点が2つ以上ある行を集める
    - 1項目に複数の文が入っている
4. 次の語を含む箇条書きの項目を集める
    - `なら`
    - `場合は`
    - `if`
    - 条件と処置が同居している
5. 箇条書き全体を見て、子項目が1つも無いものを集める
    - 理由や補足が第1階層に紛れていないか確かめる
