# grill-me

計画や設計を詰めるまでClaudeに質問させ続けるSkill。

1. 前提が決まっている質問をまとめて出す
2. ユーザーの答えで木を組み直し、次に聞ける質問を出す

質問には推奨する答えを付ける。

環境を調べればわかることはサブエージェントに投げるので、ユーザーに残るのは決めごとだけ。どこまでを調査に回すかは `Finding facts is your job` にある。

聞くことがなくなったら終わり。

`/grill-me` で呼ぶ。frontmatterに `disable-model-invocation: true` を書いて、Claude自身がこのSkillを呼ぶ経路を塞いだ。

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
SKILL.md   デザインツリー、ラウンド、出力形式、調べる範囲、終了条件
LICENSE    上流のMIT
```

## SKILL.md の直しどころ

| 直したいもの | 触る箇所 |
|---|---|
| 1ラウンドに出す質問の選び方 | Work the tree in rounds |
| 質問の見た目 | Format a round like so |
| 次のラウンドの組み立て方 | Each round the user answers |
| ユーザーに聞かず自分で調べる範囲 | Finding facts is your job |
| 終わる条件 | The session is done |
| Claudeが自分で起動するか | frontmatterの `disable-model-invocation` |
