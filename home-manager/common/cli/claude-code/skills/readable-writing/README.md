# readable-writing

AIが書いた文章特有の読みにくさを解消するClaude Skill。日本語と英語の両方を扱う。

対象は次の文書。

- 技術文書
- README
- コミットメッセージ
- PR説明
- コード内コメント
- 実装計画書

`scripts/review.sh` が観点ごとに `claude -p` を並列で起動する。集まった指摘は同じセッションで直す。成果物は修正後の文章だけ。観点ごとにポリシーを分ける構成は `pr-review` スキルと揃えてある。

## 由来

日本語のパターンは[iKora128/stop-ai-slop-jp](https://github.com/iKora128/stop-ai-slop-jp)、英語のパターンは[hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop)から取った。どちらもMIT。

## 構成

```
SKILL.md                 対象、レビューの起動、統合、修正
scripts/
└── review.sh            観点ごとに claude -p を並列起動し、findingsのJSONを返す
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
    ├── vocabulary.md
    └── symbols.md
```

日本語のレビューでは `common/` と `ja/` を全部使う。英語なら `common/` と `en/`。`review.sh` が文字種から言語を判定し、該当ファイルの中身をプロンプトに埋め込む。

1つの観点が1つの `claude -p` プロセスに対応する。各プロセスには自分の観点のファイルだけを渡す。

`common/` が持つのはパターンと直し方だけだ。禁止する語や具体的な言い回しは `ja/` と `en/` に置く。

箇条書きは形の問題だけなので `common/` にしかない。語彙は完全に言語固有なので `ja/` と `en/` にしかない。

## ルールの追加と修正

| 直したいもの | 触るファイル |
|---|---|
| 特定の語を禁止したい | `policies/<lang>/vocabulary.md` |
| 文と文の並べ方 | `policies/common/rhetoric.md` |
| その言語だけの言い回し | `policies/<lang>/<観点>.md` |
| 箇条書きの書き方 | `policies/common/lists.md` |
| 見出しと節の立て方 | `policies/common/document.md` |
| 記号の使い方 | `policies/common/symbols.md`, `policies/<lang>/symbols.md` |
| 主語の立て方 | `policies/common/agency.md` |
| 主張の強さ、引き受け方 | `policies/common/stance.md` |
| 対象文書、統合、修正 | `SKILL.md` |
| プロンプト、言語判定、並列の起動 | `scripts/review.sh` |

観点を足すときは3箇所を触る。

- `policies/` にファイルを置く
- `scripts/review.sh` の `perspectives` に行を足す
- `SKILL.md` の対応表に行を足す

同じ箇所に複数のレビュアーが付いたら、呼び出し側が1件に統合する。

## ライセンス

MIT。由来ごとの著作権表示は `LICENSE` を参照。
