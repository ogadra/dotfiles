# ponytail

Claudeに過剰実装をやめさせるSkill。コードを書く前に次の順で確認し、最初に当てはまった段で止める。

1. そもそも要るか
2. 既にコードベースにあるか
3. 標準ライブラリで足りるか

`/ponytail` で明示的に呼ぶほか、コーディング依頼では `description` を見たClaudeが自分で起動する。

- 強度
    - `lite`
    - `full`
    - `ultra`
- 既定
    - `full`

強度は `/ponytail ultra` のように呼び出しごとに渡す。

## 由来

- 上流
    - [dietrichgebert/ponytail](https://github.com/dietrichgebert/ponytail)
- ライセンス
    - MIT
- 取り込み元のコミット
    - `e3ba2aa`
    - 2026-09-14

## 構成

```
SKILL.md   ラダー、ルール、出力形式、強度、手を抜かない範囲、ハードウェア、テスト
LICENSE    上流のMIT
```

## 直したいとき

直しは `SKILL.md` に直接入れる。

| 直したいもの | 触る節 |
|---|---|
| 書く前に確認する順序 | The ladder |
| 禁じる書き方 | Rules |
| 返す文章の量と形 | Output |
| lite、full、ultraの差 | Intensity |
| 手を抜かせない範囲 | Limits |
| 残させるテスト | Tests |
| Claudeが自分で起動する条件 | frontmatterの `description` |
