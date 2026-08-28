# 記号

記号と字面を見る。

## 検出対象

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

語を同定するときにだけ括弧を使う。

- 原語の併記
    - `否定的列挙 (negative listing)`
- 略語の初出での展開
    - `RAG (Retrieval-Augmented Generation)`

それ以外の括弧は、中身が読み手に必要かで分ける。

- 必要な場合
    - 本文か1段下の階層に置く
- 必要でない場合
    - 消す

## 検出手順

1. `(` と `（` を検索する
    - 中身が原語併記でも略語の展開でもない箇所を集める
