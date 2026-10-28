# code-quality観点

差分の局所的なコーディング品質・実行時頑健性・保守性を検出する。命名・型・冗長・エラー処理 (握りつぶし以外)・リソース管理・技術的負債・保守性に絞る。

## 対象外

以下は指摘しない。

- 説明コメント、経緯コメント、AIプロースなど自然言語。
- Fail Fast欠如。silent fallback、多段 `??`、空catch、`if (!x) return`。
- 依存方向、派生値状態、抽象度混在、解決責務の一元化などレイヤ配置に関わる問題。
- 幻覚API、過剰実装、要求外の改名、見かけ上の修正などのAI特有の癖。
- 機密情報の露出、インジェクション、認可欠落など。
- テストの不足、モック品質。

## REJECTパターン

### 命名

| # | パターン | 例 |
|---|---------|-----|
| Q1 | 実体と乖離 | `openResource()` がmemoizedアクセサ |
| Q2 | 副作用の存在が名前から読めない | `getUser()` がDBを更新する |
| Q3 | ラップ元・委譲先と紛らわしい | 同名で階層違い |
| Q4 | 実装機構名の露出 | `useReduxAuthContext` のような機構名 |

### 型・null安全

| # | パターン | 例 |
|---|---------|-----|
| Q5 | `any` の使用 | `let x: any =` |
| Q6 | 型assertion / castの乱用 | `x as SomeType` で本来narrowingすべき |
| Q7 | オブジェクト/配列の直接変更 | `arr.push(x)` の破壊 (immutable想定) |
| Q8 | undefined/null混同 | 意味が違う値を区別せず扱う |

### 冗長・重複

| # | パターン | 例 |
|---|---------|-----|
| Q9 | if/elseで同一関数を引数差のみで呼び分け | `if (x) f(a,b,c) else f(a,b)` |
| Q10 | 同一実装の別名関数 | `copyFiles` と `placeFiles` が同じ処理 |
| Q11 | 同じロジックの重複 | 複数箇所に同じ判定ロジック |
| Q12 | コールバック + 外部変数キャプチャ | `let r; await f(x => r = x)` |
| Q13 | 1箇所でしか使わない設定配列 + ループ | `[{kind, fields}]` をloopで処理、`switch` で足りる |

### 未使用・未完成・到達不能

| # | パターン | 例 |
|---|---------|-----|
| Q14 | 未使用のexport / 関数 / 変数 / import | |
| Q15 | Issue番号・除去条件のないTODO/FIXME | `// TODO: fix later` |
| Q16 | 空実装・スタブの完成扱い | `return null`, `pass` |
| Q17 | 到達不能コード | 早期return後の処理、常に真/偽になる条件 |
| Q18 | 「念のため」の防御コード | 呼び出し元の制約で絶対通らない分岐 |

### エラーハンドリング

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| Q19 | catchでスタックを捨て別エラーに詰め替え | `catch (e) { throw new Error('failed') }` (`cause` を付ける) | REJECT |
| Q20 | ユーザー向けエラーメッセージが不明確 | `throw new Error('error')`, `'Something went wrong'` | 修正必要 |
| Q21 | 各所でのtry-catch散在 | ドメイン層で500応答を組み立て | REJECT |
| Q22 | システム境界でのバリデーション欠如 | 外部入力を型assertのみで受ける | Warning |

### ログ

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| Q23 | `console.log`, `print(` の本番残置 | 追加行に `console.log(...)` | REJECT |
| Q24 | 新規コードパスにデバッグログなし | 例外経路・分岐にlogがない | Warning |
| Q25 | ログレベル誤用 | エラー相当をinfo、警告レベルをerror | Warning |

### 技術的負債

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| Q26 | 理由なしの `@ts-ignore` / `@ts-expect-error` | | Warning |
| Q27 | 理由なしの `eslint-disable` / `noqa` | | Warning |
| Q28 | 非推奨APIの新規使用 | deprecated関数の呼び出し追加 | Warning |

### 書き込み後の副作用

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| Q29 | 書き込み先ディレクトリを直後にスキャン | ファイル生成 → 同ディレクトリをreaddir | REJECT |
| Q30 | 一時ファイルの読み戻し | 一時ディレクトリに書いて同ディレクトリを全走査 | REJECT |
| Q31 | 生成物が次パイプラインの入力になる | 自己参照的処理 | Warning |

### リソース管理

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| Q32 | ファイル / 接続 / ロックのclose忘れ | try-finally / with / deferの欠落 | REJECT |
| Q33 | タイマー・購読・イベントリスナのクリーンアップ欠落 | React `useEffect` のcleanup未実装 | REJECT |
| Q34 | 同一副作用の重複実行 | idempotentでない処理がリトライで多重発火 | REJECT |

### プロジェクト規約

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| Q35 | プロジェクトスクリプトの迂回 | `npx tool` 直接実行を追加 | REJECT |
| Q36 | 契約文字列のハードコード散在 | ファイル名・キーがリテラルで複数箇所 | REJECT |
| Q37 | Stateful regexの危険な使用 | モジュールスコープ `/g` を `test()` と `replace()` で併用 | REJECT |

### 保守性

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| Q38 | 関数が長すぎる | 30行超で複数責務 | Warning |
| Q39 | ファイルが長すぎる | 300行超で複数責務 | Warning |
| Q40 | 過度な汎用化 | `formatValue(v, type, opts)` でtype分岐 | 修正必要 |

## 検出手順

1. diff内の `any`, `as `, `// TODO`, `// FIXME`, `@ts-ignore`, `@ts-expect-error`, `eslint-disable` をgrepする。
2. 追加された関数の本体を、同ファイル・近傍モジュールの既存関数と比較して重複を確認する。
3. if/elseが同関数を差分引数で呼んでいる箇所を確認する。
4. 関数名・変数名が実体と一致するかコードを読んで確認する。
5. 追加されたimportが実際に使われているか確認する。
6. `console.log`, `print(`, `println!`, `System.out` の追加を検索する。
7. ファイル書き込み後に `readdir`, `glob`, `scandir`, `walk` を呼ぶ箇所がないか確認する。
8. 開いたリソース (`open`, `connect`, `createReadStream`, `addEventListener`, `setInterval`) に対してclose/cleanupがあるか確認する。
9. `try`, `catch`, `except`, `.catch(`, `.then(` を確認し、原因情報喪失や散在がないか確認する。

## 出力ルール

- REJECTの指摘は、修正後のコード例を1案示す。
- 命名系は代替名を1〜2個提示する。
- 保守性系 (Q38-Q39) はWarningが原則。
