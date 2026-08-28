# readable-writing

AIが書いた文章特有の読みにくさを解消するClaude Skill。

対象は次の文書。

- 技術文書
- README
- コミットメッセージ
- PR説明
- コード内コメント
- 実装計画書

`scripts/review.sh` が観点ごとに `claude -p` を並列で起動する。集まった指摘は同じセッションで直す。成果物は修正後の文章だけ。

## 由来

日本語のパターンは[iKora128/stop-ai-slop-jp](https://github.com/iKora128/stop-ai-slop-jp)、英語のパターンは[hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop)をベースに改変。どちらもMIT。

## 構成

```
SKILL.md                 対象、レビューの起動、統合、修正
scripts/
├── review.sh            観点ごとに claude -p を並列起動し、findingsのJSONを返す
└── mechanical.pl        正規表現で確定判定できる記号を集める
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

`common/` が持つのはパターンと直し方だけだ。禁止する語や具体的な言い回しは `ja/` と `en/` に置く。箇条書きは形の問題なので `common/` にしかなく、語彙は言語固有なので `ja/` と `en/` にしかない。

## 動作

`review.sh` が言語を判定し、該当ファイルの中身をプロンプトに埋め込む。日本語なら `common/` と `ja/`、英語なら `common/` と `en/`、混ざっていれば3つとも渡す。

判定は行数で決める。日本語の文字を含む行と、英単語が4語以上続く行を数え、少ないほうが5%を超えたら混在とみなす。

1つの観点が1つの `claude -p` プロセスに対応し、各プロセスには自分の観点のファイルだけを渡す。

- `mechanical.pl` で拾うもの
    - `common/`
        - 文中での改行
        - 本文中の強調
        - 装飾絵文字
    - `ja/`
        - 全角ダッシュ
        - 中黒並列
        - 地の文のコロン
        - 不要な半角スペース
    - `en/`
        - Em dashes
- `claude -p` に渡すもの
    - 括弧による後置補足
        - 中身が原語の併記かを読む
    - 評価を囲む鉤括弧
        - 固有名詞かを読む
    - Scare quotes
        - 直接引用かを読む

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
| 正規表現で決まる記号の検出 | `scripts/mechanical.pl` |

観点を足すときは下記の3箇所を修正する。

- `policies/` にファイルを置く
- `scripts/review.sh` の `perspectives` に行を足す
- `SKILL.md` の対応表に行を足す

## ライセンス

MIT
