---
name: absolute-rules
description: Use by any agent before writing specs, editing code, or changing workflow
files when the change could add compatibility behavior, aliases, silent fallbacks, or
default-value fallbacks.
---

- 明示的な要求がない限り、後方互換のための実装をしない。実装をシンプルに保つため破壊的変更を選ぶ。旧関数名の残置や「以前は〜」のような経緯コメントも残さず、最初からそうだったコードベースに書き換える。
- 互換レイヤやsilent fallback、代替経路を勝手に足さない。
- fallbackは禁止。安全に継続できない箇所は、明確なエラーをraiseする。`os.getenv("FOO", "default")`のようなデフォルト引数によるフォールバックも同じく禁止。
