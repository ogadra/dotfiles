# ponytail

過剰実装を抑えるClaude Skill。コードを書く前に、そもそも要るか、既にコードベースにあるか、標準ライブラリで足りるか、と順に確認し、最初に当てはまった段で止める。

`/ponytail` で明示的に呼ぶほか、コーディング依頼では `description` を見たClaudeが自分で起動する。強度は `lite`、`full`、`ultra` の3段階で、既定は `full`。

## 由来

- [dietrichgebert/ponytail](https://github.com/dietrichgebert/ponytail)
- MIT
- 取り込み元のコミットは `e3ba2aa`（2026-09-14）

`SKILL.md` は上流のものをそのまま置いている。以降は上流に追従せず、このリポジトリで直接直す。

## 上流から持ってこなかったもの

上流は20以上のエージェントとエディタに対応するプラグインで、その大半はこの環境には要らない。

| 持ってこなかったもの | 理由 |
|---|---|
| `hooks/` のNodeスクリプト | Cursor、Copilot、Codex、Qoderへの分岐が大半 |
| SessionStartでのルール常時注入 | スキルとして呼ぶ形にした。常時適用にするなら `hooks.nix` にSessionStartを足す |
| フラグファイル `~/.claude/.ponytail-active` | 強度はスキルの引数で渡す |
| statusline表示 | `settings.nix` の `statusLine` が埋まっている |
| `ponytail-review`、`-audit`、`-debt`、`-gain`、`-help` | 本体だけで足りる。要るものが出たら上流から個別に持ってくる |

フラグファイルがないので、`SKILL.md` の「Level persists until changed or session end」は成り立たない。強度を変えるときは `/ponytail ultra` のように毎回渡す。

## 構成

```
SKILL.md   ラダー、ルール、出力形式、強度、手を抜かない範囲
LICENSE    上流のMIT
```

## 直したいとき

触るのは `SKILL.md` の1ファイルだけ。

| 直したいもの | 触る節 |
|---|---|
| 書く前に確認する順序 | The ladder |
| 禁じる書き方 | Rules |
| 返す文章の量と形 | Output |
| lite、full、ultraの差 | Intensity |
| 手を抜かせない範囲 | When NOT to be lazy |
| 自動起動する条件 | frontmatterの `description` |

## ライセンス

MIT。上流の `LICENSE` をそのまま同梱している。
