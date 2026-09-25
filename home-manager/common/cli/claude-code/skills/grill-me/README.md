# grill-me

計画や設計を詰めるまでClaudeに質問させ続けるSkill。

1. 前提が決まっている質問をまとめて出す
2. ユーザーの答えで木を組み直し、次に聞ける質問を出す

質問はAskUserQuestionツールで出す。質問の本文と選択肢がUIに並び、推奨する答えが先頭に来る。1回の呼び出しに入るのは4問までなので、それを超えるラウンドは呼び出しを分ける。

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
- 上流からの変更
    - 質問を本文のマークダウンではなくAskUserQuestionツールで出す

## 構成

```
SKILL.md   デザインツリー、ラウンド、質問の出し方、調べる範囲、終了条件
LICENSE    上流のMIT
```

## SKILL.md の直しどころ

| 直したいもの | 触る箇所 |
|---|---|
| 1ラウンドに出す質問の選び方 | Work the tree in rounds |
| 質問の出し方、選択肢の作り方 | Put every question through the AskUserQuestion tool |
| 次のラウンドの組み立て方 | Each round the user answers |
| ユーザーに聞かず自分で調べる範囲 | Finding facts is your job |
| 終わる条件 | The session is done |
| Claudeが自分で起動するか | frontmatterの `disable-model-invocation` |
