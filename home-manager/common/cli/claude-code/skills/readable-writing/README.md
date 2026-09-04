# readable-writing

AIが書いた文章特有の読みにくさを解消するClaude Skill。

対象は次の文書。

- 技術文書
- README
- コミットメッセージ
- PR説明
- コード内コメント
- 実装計画書

`scripts/review.sh` が観点ごとに `claude -p` を並列で起動する。集まった指摘は、スキルを呼んだClaudeが同じセッションで直し、修正後の文章だけを返す。

## 由来

ベースにしたもの。

- 日本語のパターン
    - [iKora128/stop-ai-slop-jp](https://github.com/iKora128/stop-ai-slop-jp)
- 英語のパターン
    - [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop)
- どちらもMIT

## 構成

```
SKILL.md                 対象、レビューの起動、統合、修正
scripts/
├── review.sh            観点ごとに claude -p を並列起動し、findingsのJSONを返す
├── mechanical.pl        正規表現で確定判定できるものを集める
└── rules/               mechanical.pl が使う語リスト
    ├── ja.pl
    └── en.pl
prompts/                 レビュアーへの指示
├── judgement.md         何を指摘し何を見送るか
└── fields.md            findingsの各フィールドに入れるもの
policies/
├── common/              言語非依存のパターンと直し方
│   ├── stance.md
│   ├── agency.md
│   ├── lists.md
│   ├── document.md
│   ├── rhetoric.md
│   └── symbols.md
├── ja/                  日本語の言い回しと例
│   ├── stance.md
│   ├── agency.md
│   ├── document.md
│   ├── rhetoric.md
│   ├── vocabulary.md
│   └── symbols.md
└── en/                  英語の言い回しと例
    ├── stance.md
    ├── agency.md
    ├── document.md
    ├── rhetoric.md
    └── symbols.md
```

## ポリシーの選択

`review.sh` が言語を判定し、該当ファイルの中身をプロンプトに埋め込む。

- 日本語
    - `common/`
    - `ja/`
- 英語
    - `common/`
    - `en/`
- 混在
    - `common/`
    - `ja/`
    - `en/`

## ルールの追加と修正

| 直したいもの | 触るファイル |
|---|---|
| 禁止する語 | `scripts/rules/<lang>.pl` の `@LITERAL` |
| 系統ごとの出現回数で見る語 | `scripts/rules/ja.pl` の `@FAMILY` |
| 何を指摘し何を見送るか | `prompts/judgement.md` |
| findingsの各フィールドの中身 | `prompts/fields.md` |
| 文と文の並べ方 | `policies/common/rhetoric.md` |
| その言語だけの言い回し | `policies/<lang>/<観点>.md` |
| 箇条書きの書き方 | `policies/common/lists.md` |
| 見出しと節の立て方 | `policies/common/document.md` |
| 記号の使い方 | `policies/common/symbols.md`, `policies/<lang>/symbols.md` |
| 主語の立て方 | `policies/common/agency.md` |
| 主張の強さ、引き受け方 | `policies/common/stance.md` |
| 対象文書、統合、修正 | `SKILL.md` |
| プロンプトの組み立て、言語判定、並列の起動 | `scripts/review.sh` |
| 正規表現で決まる規則の検出 | `scripts/mechanical.pl` |

観点を足すときに触る場所。

- `policies/`
    - ファイルを置く
- `scripts/review.sh`
    - `perspectives` に行を足す
- `SKILL.md`
    - 対応表に行を足す

## ライセンス

MIT
