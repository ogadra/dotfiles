# grill-me

Claudeが、計画や設計を詰めるまで質問し続ける。

1. 前提が決まっている質問をまとめて出す
2. ユーザーの答えで木を組み直す

質問はAskUserQuestionツールで出す。

- UIに並べるもの
    - 本文
    - 選択肢は推奨する答えを先頭に置く
- 1回の呼び出しに入る質問
    - 4問ごとに呼び出しを分ける

環境を調べればわかることはサブエージェントに投げる。

`/grill-me` で呼ぶ。frontmatterに `disable-model-invocation: true` を置いている。

## 由来

- 上流
    - [mattpocock/skills](https://github.com/mattpocock/skills)
        - `skills/productivity/grill-me`
        - `skills/productivity/grilling`
- ライセンス
    - MIT
- 取り込み元のコミット
    - `c55ee46`
    - 2026-09-18

## 構成

```
SKILL.md   デザインツリー、ラウンド、質問の出し方、調べる範囲、終了条件
LICENSE    上流のMIT
```

## SKILL.mdの直しどころ

| 直したいもの | 触る箇所 |
|---|---|
| 1ラウンドに出す質問の選び方 | Work the tree in rounds |
| 質問の出し方 | Put each question through the AskUserQuestion tool |
| 自分で調べる範囲 | Dispatch a sub-agent |
| 終わる条件 | The session is done |
| Claudeが自分で起動するか | frontmatterの `disable-model-invocation` |
