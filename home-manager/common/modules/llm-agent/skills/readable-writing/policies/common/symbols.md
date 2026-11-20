# 記号

## 検出対象

### 括弧による後置補足

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

どの語かを示すときにだけ括弧を使う。

- 原語の併記
    - `否定の前置き (negative listing)`
- 略語が初めて出る箇所での正式名称
    - `RAG (Retrieval-Augmented Generation)`

それ以外の括弧は中身が読み手に必要か確かめて分ける。

- 必要な場合
    - 本文に置く
    - または1段下の階層に置く
- 必要でない場合
    - 消す

## 検出手順

1. 括弧を探す
    - 探す記号
        - `(`
        - `（`
    - 次のどちらでもない箇所を集める
        - 原語の併記
        - 略語が初めて出る箇所での正式名称
