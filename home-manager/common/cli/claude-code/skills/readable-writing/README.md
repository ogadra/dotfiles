# readable-writing

AIが書いた文章特有の読みにくさを解消するClaude Skill。

対象は次の文書。

- 技術文書
- README
- コミットメッセージ
- PR説明
- コード内コメント
- 実装計画書

`scripts/review.sh` が観点ごとに `claude -p` を並列で起動する。集まった指摘は同じセッションで直し、修正後の文章だけを返す。

## 由来

日本語のパターンは[iKora128/stop-ai-slop-jp](https://github.com/iKora128/stop-ai-slop-jp)、英語のパターンは[hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop)をベースに改変。どちらもMIT。

## 構成

```
SKILL.md                 対象、レビューの起動、統合、修正
scripts/
├── review.sh            観点ごとに claude -p を並列起動し、findingsのJSONを返す
└── mechanical.pl        正規表現で確定判定できるものを集める
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

## 動作

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

言語は行数で決める。日本語の文字を含む行と、英単語が4語以上続く行を数え、少ないほうが5%を超えたら混在とみなす。

1つの観点が1つの `claude -p` プロセスに対応し、各プロセスには自分の観点のファイルだけを渡す。

閉じたリストと形だけで決まる規則は `mechanical.pl` が拾う。

| 観点 | `mechanical.pl` が拾う |
|---|---|
| 記号 | 文中での改行、本文中の強調、装飾絵文字、全角ダッシュ、中黒並列、地の文のコロン、不要な半角スペース、Em dashes |
| 語彙 | 日本語10節と英語9節の語リスト、系統ごとの出現回数、副詞の重ね掛け、文末の敬体 |
| 文書構成 | 見出しの代用 |
| 箇条書き | 平坦な箇条書きのうち `- **` 始まりと第1階層の句点 |
| 修辞 | 記号によるbad-then-good比較 |
| 主体 | アカデミック自称 |

`claude -p` には、検索した語を見てから確かめる規則を残す。

- 括弧による後置補足
    - 中身が原語の併記かを読む
- 評価を囲む鉤括弧
    - 固有名詞かを読む
- 翻訳調動詞
    - 主語が無生物かを読む

`遠くから語る話者` の「人々」「多くの」はAI版の表からの抜き出しなので、`claude -p` が読む。

## ルールの追加と修正

| 直したいもの | 触るファイル |
|---|---|
| 特定の語を禁止したい | `scripts/mechanical.pl` の `@LITERAL` |
| 系統ごとの出現回数で見る語 | `scripts/mechanical.pl` の `@FAMILY` |
| 文と文の並べ方 | `policies/common/rhetoric.md` |
| その言語だけの言い回し | `policies/<lang>/<観点>.md` |
| 箇条書きの書き方 | `policies/common/lists.md` |
| 見出しと節の立て方 | `policies/common/document.md` |
| 記号の使い方 | `policies/common/symbols.md`, `policies/<lang>/symbols.md` |
| 主語の立て方 | `policies/common/agency.md` |
| 主張の強さ、引き受け方 | `policies/common/stance.md` |
| 対象文書、統合、修正 | `SKILL.md` |
| プロンプト、言語判定、並列の起動 | `scripts/review.sh` |
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
