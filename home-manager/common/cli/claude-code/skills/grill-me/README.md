# grill-me

計画や設計を詰めるまでClaudeに質問させ続けるSkill。

1. 前提が決まっている質問をまとめて出す
2. ユーザーの答えで木を組み直す

質問はAskUserQuestionツールで出す。本文と選択肢をUIに並べ、推奨する答えを先頭に置く。1回の呼び出しに入るのは4問までなので、それを超えるラウンドは呼び出しを分ける。

環境を調べればわかることはサブエージェントに投げるので、ユーザーに残るのは決めごとだけ。どこまでを調査に回すかは `Finding facts is your job` にある。

聞くことがなくなったら止める。

`/grill-me` で呼ぶ。frontmatterの `disable-model-invocation: true` で、起動はユーザーからだけになる。

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
| 次のラウンドの組み立て方 | Once the user answers |
| ユーザーに聞かず自分で調べる範囲 | Finding facts is your job |
| 終わる条件 | The session is done |
| Claudeが自分で起動するか | frontmatterの `disable-model-invocation` |
