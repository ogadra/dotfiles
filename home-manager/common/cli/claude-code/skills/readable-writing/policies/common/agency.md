# 主体

誰が何をしたかを見る。人が書く文章では必ず誰かが何かをしている。AIが書く文章では、状況や概念が勝手に動く。

言語ごとの言い回しは `ja/agency.md` と `en/agency.md` にある。

## 検出対象

### false agency

モノに人間の動作をさせる形。無生物が能動的な動詞を取っていたら、誰がやったのかを考えて主語に立て直す。

#### AI版

```
このアーキテクチャがチーム全体の生産性を引き上げた。設計がスケールの限界を決める。

The architecture lifted the whole team's productivity. The design decides where scale runs out.
```

#### 修正版

```
このアーキテクチャに移してから、1機能を足すのに触るファイルが3つから1つになった。スケールの限界は、キューの並列数を決めたときに自分たちが決めた。

Since we moved to this architecture, adding a feature touches one file instead of three. We set the scale ceiling ourselves when we chose the queue concurrency.
```

#### 修正の型

「誰が」を主語に立てる。具体的な誰かが思いつかないなら、その文は具体性が足りない。書き手がその話を持っていない可能性が高い。特定の個人が当てはまらない場合、読み手を主語に置く。

### 実装判断の壮大化

一つの実装判断を抽象命題に変換する形。判断そのものを主語にして「思想」「設計」「装置」を当てる。

#### AI版

```
リトライ回数を3回に決めたことは、信頼性と即応性のトレードオフをどう引き受けるかという設計思想の表明だった。

Capping retries at three was a statement of design philosophy about how we take on the tradeoff between reliability and responsiveness.
```

#### 修正版

```
リトライは3回にした。4回目以降で成功した例が過去1ヶ月で0件だったからだ。

We capped retries at three. Nothing succeeded on the fourth attempt or later in the past month.
```

#### 修正の型

設計判断やトラブル対応に、すべて教訓を付けない。「こう直したら直った」で終わる記述を残す。一般化するのは、他のケースでも再現すると確かめたときだけ。

壮大化に使われる語彙は `ja/vocabulary.md` の必殺技造語を参照。

### 受動態

行為者を隠す形。

#### AI版

```
このエンドポイントは負荷試験で問題が発見されたため、キャッシュが追加された。

Problems were found in this endpoint during load testing, so a cache was added.
```

#### 修正版

```
負荷試験でこのエンドポイントが500msを超えたので、キャッシュを挟んだ。

Load testing put this endpoint over 500ms, so I put a cache in front of it.
```

#### 修正の型

行為者を見つけて文頭に置く。

### 遠くから語る話者

上から社会を論じ、読者を場に置かない形。

#### AI版

```
現代の開発者は、ビルド時間の長さに慣れきってしまっている。我々はその代償を無自覚に払い続けている。

Developers today have grown numb to long build times. We keep paying the price without noticing.
```

#### 修正版

```
あなたのビルドが9分かかっていて1日6回回すなら、30分待っている。自分はそれを3ヶ月放置していた。

If your build takes nine minutes and you run it six times a day, you're waiting half an hour. I left mine alone for three months.
```

#### 修正の型

読み手を場に置く。「人々」「誰も」「我々」を「自分」「あなた」に書き換える。

### 一人称の消失

自分の話を世間全体の話にすり替える形。

#### AI版

```
一般に、キャッシュの導入はビルド時間の短縮に効果があるとされている。多くのプロジェクトで採用されている手法だ。

Caching is generally considered effective for cutting build times. It's a widely adopted technique.
```

#### 修正版

```
このリポジトリでは、`actions/cache` を足したら初回ビルドが9分から3分になった。

In this repository, adding `actions/cache` took the first build from nine minutes to three.
```

#### 修正の型

一般論だけの段落は情報量がゼロに近い。具体的な人、具体的なエピソード、具体的な失敗、数値、固有名詞を入れる。入れられないなら、書き手がその話を持っていない。

## 検出手順

1. 無生物が能動的な動詞を取っている箇所
    - 各文の主語を抜き出す
    - 該当する箇所を集める
2. 受動態の文
    - 該当する文を集める
    - 行為者が本文中に書かれているか確かめる
3. 集団を指す語
    - 該当する語で検索する
    - 具体的な誰かに置き換えられるか確かめる
4. 一般論だけで進む段落
    - 該当する段落を探す
    - 固有名詞と数値が入っているか確かめる
