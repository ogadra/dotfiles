# security観点

差分にセキュリティ上のリスクが混入していないかを検出する。

## 対象外

以下は指摘しない。

- セキュリティ上のリスクがない一般的なエラー握りつぶしやデバッグログの残置。
- Fail Fast欠如。`??` の乱用や多段フォールバック。
- 命名、冗長分岐、保守性など局所的な書き方。
- テストの過不足。

## REJECTパターン

### 機密情報の露出

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| SEC1 | ハードコード | パスワード、APIキー、トークン、DB接続文字列がコード・設定・テストfixtureに直書き | REJECT |
| SEC2 | ログ・エラー・スナップショットへの機密混入 | `console.log(req)`, `console.log(user)`, `Snapshot { password: '…' }` | REJECT |
| SEC3 | エラーレスポンスへのスタックトレース・内部情報露出 | 500応答にstackを含める | REJECT |
| SEC4 | 個人情報のデバッグログ | 本番で無効化される想定のログにメールアドレス・電話番号を残す | Warning |

### インジェクション

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| SEC5 | SQLインジェクション | `db.query("SELECT … WHERE id = " + userId)` 文字列連結 | REJECT |
| SEC6 | コマンドインジェクション | `exec(userInput)`, `shell=True` + ユーザー入力 | REJECT |
| SEC7 | パス走査 | ユーザー入力を `path.join` してファイル読み書き、`..` の検証なし | REJECT |
| SEC8 | XSS | `dangerouslySetInnerHTML`, `innerHTML = userInput`, `v-html` で未エスケープ | REJECT |
| SEC9 | SSRF | ユーザー入力のURLを検証なしでfetch/axios/requests | REJECT |
| SEC10 | 正規表現DoS | `.*.*` `(a+)+` のようなcatastrophic backtracking | Warning |

### 認証・認可

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| SEC11 | 認可チェック欠落 | 新しいAPI endpointにauth middlewareがない | REJECT |
| SEC12 | 認可判定をUI/フロントに委譲 | サーバー側で権限を再チェックしていない | REJECT |
| SEC13 | セッションID / トークンをURL / GETパラメータで送信 | `?token=xxx` | REJECT |
| SEC14 | パスワードの弱いハッシュ | md5, sha1, 平文保存 | REJECT |
| SEC15 | 権限チェックのバイパス | `--no-verify`, `sudo`, `skip auth` フラグの新設 | REJECT |

### 暗号・乱数

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| SEC16 | セキュア用途に非セキュア乱数 | `Math.random()`, `random.random()` をtoken/secret生成に使用 | REJECT |
| SEC17 | 自前暗号 | 独自の暗号アルゴリズム、モードなしAES、ECBモード | REJECT |
| SEC18 | ハードコードされた鍵/IV | ソース内に鍵定数 | REJECT |

### 依存・設定

| # | パターン | 例 | 判定 |
|---|---------|-----|------|
| SEC19 | CORS `*` の解禁 | `Access-Control-Allow-Origin: *` を認証エンドポイントで | REJECT |
| SEC20 | CSP / SRI / セキュアヘッダの削除 | 既存の `helmet`、`Content-Security-Policy` を外す | REJECT |
| SEC21 | 検証なしの署名/JWT | `verify: false`, `algorithms: ['none']` | REJECT |
| SEC22 | `.env`, credentials, 秘密鍵ファイルのコミット | 追加ファイルに `.env`, `id_rsa`, `.p12` | REJECT |

## 検出手順

1. diff内の以下のキーワードをgrepする。
   - `password`, `secret`, `api[_-]?key`, `token`, `credential`, `bearer`
   - `exec(`, `spawn(`, `shell=True`, `os.system`
   - `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `eval(`
   - `Math.random`, `random.random`
   - `md5`, `sha1`
   - `.env`, `id_rsa`, `.pem`, `.p12`
2. 追加されたendpoint・ルート・ハンドラに認可チェックがあるか確認する。
3. ユーザー入力 (`req.body`, `req.query`, `req.params`, argv, stdin) がSQL、shell、path、URLに流れる箇所を追跡する。
4. 認証・認可・暗号関連の設定変更がある場合、変更理由がPR本文にあるか確認する。

## 出力ルール

- CVEの推測よりdiffの該当箇所を明示。ファイル・行・実際の脆弱コードを引用。
- 修正案は「エスケープ関数の使用」「パラメータ化クエリ」「認可middlewareの追加」など具体名で示す。
