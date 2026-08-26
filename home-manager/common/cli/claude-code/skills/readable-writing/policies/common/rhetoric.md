# 修辞

文と文の並べ方に出る型を見る。平坦な内容に構文で起伏をつけるクセと、リズムが均一になるクセを扱う。単語のリストで検出するものは `ja/vocabulary.md` と `en/vocabulary.md` にある。

言語ごとの言い回しは `ja/rhetoric.md` と `en/rhetoric.md` にある。

## 検出対象

### 二項対比

「XではなくYだ」を使う形。直接Yを書けば済む。

#### AI版

```
このスキルは文章を綺麗にするものではなく、書き手を文面に戻すものだ。

This skill isn't about polishing prose, it's about putting the writer back into it.
```

#### 修正版

```
このスキルは、書き手が何を見て何に引っかかったかを文面に残す。

This skill keeps what the writer saw and got stuck on in the text.
```

#### 修正の型

否定は範囲を狭めて伝える書き方なので、消すと情報が落ちる。落ちた分は肯定文の側を広げて埋める。

- 「3本まとめて採点するのではなく、2本で採点する」
    - 「採点は該当する2本で行う」
- "We don't grade all three, we grade two."
    - "Grade the two that apply."

対比そのものを残したいなら、XとYの違いを具体的に書く。比較の軸を名指しする。

- 「速いより正確なほうが効く場面だった」
- "Accuracy mattered more than speed here."

### 否定的列挙

何かを示す前に「何でないか」を並べる形。

#### AI版

```
これはリンターではない。フォーマッタでもない。文体チェッカーでもない。文章から書き手が消えている箇所を見つけるツールだ。

This isn't a linter. It isn't a formatter. It isn't a style checker. It finds the places where the writer has vanished from the text.
```

#### 修正版

```
文章から書き手が消えている箇所を見つけるツールだ。

It finds the places where the writer has vanished from the text.
```

#### 修正の型

言いたいものを最初に書く。

### 劇的な断片化

短文を連発して深さを演出する形。句点で間を作ろうとする。

#### AI版

```
原因はキャッシュだった。それだけ。9分が3分に。たったそれだけの話。

The cause was the cache. That's it. Nine minutes to three. That simple.
```

#### 修正版

```
原因はキャッシュだった。挟んだら9分のビルドが3分になった。

The cause was the cache. Adding one took the build from nine minutes to three.
```

#### 修正の型

完全な文に戻す。

### 修辞疑問

洞察を届けずに、洞察があると予告する形。

#### AI版

```
では、なぜビルドはこれほど遅かったのか? 答えは意外なところにあった。

So why was the build so slow? The answer was somewhere I didn't expect.
```

#### 修正版

```
ビルドが遅かったのは、キャッシュを挟んでいなかったからだった。

The build was slow because there was no cache in front of it.
```

#### 修正の型

問いを立てずに答えを書く。実際に何をしたかから入る。

### 決めつけ序文

冒頭で強い断定を投げ、すぐ反転させる形。英語ブログのhook構造の直訳。

#### AI版

```
多くの開発者はビルド時間を軽視している。だが、実際にはそれが最も大きなボトルネックだ。

Most developers don't take build times seriously. In reality, it's the biggest bottleneck they have.
```

#### 修正版

```
自分はビルドが9分かかることを3ヶ月放置していた。計測したら、待ち時間が1日30分あった。

I left a nine-minute build alone for three months. When I measured, I was waiting half an hour a day.
```

#### 修正の型

冒頭の決めつけを「自分は○○だった」に書き換える。実際に見たことから入るほうが、読み手は根拠を追える。

### 記号によるbad-then-good比較

絵文字のチェックとバツで対比する構造。スライドやSEO記事の型。

#### AI版

```
❌ 古いやり方
✅ 新しいやり方

❌ The old way
✅ The new way
```

#### 修正版

```
古いやり方だと1箇所の変更で3ファイル触っていた。新しいやり方は1ファイルで済む。

The old way made us edit three files for one change. The new way touches one.
```

#### 修正の型

対比は地の文に展開する。

### 定型の語り出し

物語のテンプレートをそのまま当てはめる形。

#### AI版

```
すべては1本のissueから始まった。最初は誰も気に留めなかった。しかし、そこから物語は動き出す。

It all started with a single issue. Nobody paid attention at first. But that's where the story begins.
```

#### 修正版

```
7月に「ビルドが遅い」というissueが立った。2ヶ月動きがなく、9月に自分が計測した。

Someone filed a "builds are slow" issue in July. It sat for two months. I measured it in September.
```

#### 修正の型

何が起きたかを時系列で書く。

### 一文圧縮

年代、人名、定義、評価を並列で1文か2文に詰める形。

#### AI版

```
1958年にニューヨークで生まれたBauerは、認知科学の草分けとして知られ、その理論は現在も高く評価されている。

Born in New York in 1958, Bauer was a pioneer of cognitive science whose theories remain highly regarded today.
```

#### 修正版

```
Bauerは1958年にニューヨークで生まれた。認知科学の初期の研究者で、読んだ伝記にはこの分野を作った一人だとある。理論が今どう扱われているかは調べていない。

Bauer was born in New York in 1958. He was an early cognitive science researcher; the biography I read calls him one of the field's founders. I didn't look into how his theories are treated now.
```

#### 修正の型

文を分ける。調べただけの事実には出所が伝わる書き方を選び、辞書のような断定型を避ける。自分で検証したことは断定で書く。

### 3項目並列

3つ並べたがるクセ。「3つのポイント」のような見出しに出る。

#### AI版

```
## 導入で得られる3つのメリット

- ビルドが速くなる
- CIのコストが下がる
- 開発者体験が向上する

## Three benefits you get

- Faster builds
- Lower CI costs
- Better developer experience
```

#### 修正版

```
## 導入で変わること

- 初回ビルドが9分から3分になる

## What changes

- The first build goes from nine minutes to three
```

#### 修正の型

3項目に出会ったら、2つか1つに削る。削れないなら、3つとも要る理由を書く。

### ムラの欠如

段落の長さもトーンも揃う形。揃っているほど、読み手は書き手が迷わず一定の関心で書いたと受け取る。

#### AI版

```
キャッシュを挟むとビルドが速くなる。9分が3分になった。効果は大きい。

CIのコストも下がる。実行時間が短くなるためだ。月額も減る。

開発者の待ち時間も減る。1日30分の削減になる。集中も途切れにくい。

Caching makes the build faster. Nine minutes became three. The effect is large.

CI costs drop too. The runs are shorter. The monthly bill goes down.

Developers wait less. That is thirty minutes a day. Focus breaks less often.
```

#### 修正版

```
キャッシュを挟んだら9分のビルドが3分になった。

CIのコストも下がったはずだが、請求はまだ見ていない。

効いたのは待ち時間のほうだ。9分あるとブランチを切り替えて別のことを始めてしまい、戻ってきたときに何をしていたか思い出すところからやり直していた。3分なら待てる。1日30分の削減、と書くと小さく見える。

Caching took the build from nine minutes to three.

CI costs should be down too. I haven't looked at the bill.

The waiting is what actually mattered. At nine minutes I would switch branches and start something else, then come back and spend the first stretch remembering what I had been doing. Three minutes I can sit through. Thirty minutes a day sounds small written down.
```

#### 修正の型

5種類のムラを意識して残す。

- 長さのムラ
    - 段落と文の長さをバラバラにする
    - 1行で終わる段落と10行続く段落を混ぜる
- 密度のムラ
    - 興味のある話題には固有名詞や数値を詰める
    - 興味のないところはサラっと流す
- トーンのムラ
    - 急に冷めた書き方になる
    - 面倒くさそうになる
- 結論のムラ
    - ある段落はきれいに着地させる
    - 別の段落は「で、結局なんだったんだろう」で終わらせる
- 詳細度のムラ
    - ここだけ詳しく書く
    - ここは雑に書く

### 段落の均一な閉じ方

全段落を律儀に着地させる形。

#### AI版

```
キャッシュを挟んだら9分のビルドが3分になった。効果は大きかった。

CIのコストも下がった。これも見逃せない改善だ。

待ち時間も減った。開発体験の向上につながった。

Caching took the build from nine minutes to three. The effect was significant.

CI costs came down as well. That is another improvement worth noting.

Waiting time dropped too. This led to a better developer experience.
```

#### 修正版

```
キャッシュを挟んだら9分のビルドが3分になった。

CIのコストも下がった。請求書はまだ見ていない。

待ち時間が減ったのが一番効いた。

Caching took the build from nine minutes to three.

CI costs came down too. I haven't seen the bill yet.

The waiting is what mattered most.
```

#### 修正の型

段落の終わり方をバラけさせる。途中で文を切ったり、結論を出さずに次へ行ったりを混ぜる。

### pull-quote調

そのまま切り出して引用できる一文を狙って書く形。文の見栄えが内容から離れる。

- 段落の最後に、内容を要約した短い一文を置く
- 前後の文脈なしで成立する箴言を書く

#### AI版

```
結局のところ、速いビルドとは待たないビルドではなく、待っていることを忘れられるビルドなのだ。

In the end, a fast build isn't one you don't wait for. It's one you forget you're waiting for.
```

#### 修正版

```
9分だと待っている間に別のことを始めてしまうが、3分なら画面を見たまま待てる。

At nine minutes I start something else while I wait. At three I can just watch the screen.
```

#### 修正の型

引用されそうな形の一文を見つけたら、内容を前後の文に戻して書き直す。

### 文頭のクセ

同じ語で文を始めるクセ。

#### AI版

```
このスキルは7観点でレビューする。このスキルは日本語と英語に対応する。このスキルはポリシーを3つに分けている。

This skill reviews from seven perspectives. This skill handles Japanese and English. This skill splits its policies into three directories.
```

#### 修正版

```
このスキルは7観点でレビューする。日本語と英語のどちらでも動き、ポリシーは3つに分かれている。

This skill reviews from seven perspectives. It works in Japanese and English, and its policies live in three directories.
```

#### 修正の型

繰り返している語を含む文を、別の語から始まる形に書き直す。

## 検出手順

1. 否定のあとに肯定が続く形を集める。
2. 否定が3回以上続く箇所を探す。
3. 名詞で終わる短文が3つ以上連続する箇所を探す。
4. 疑問文を集め、直後に答えが書かれているものを指摘する。
5. 冒頭の段落を読み、断定から反転に入っていないか確かめる。
6. 「3つの」「three」で検索する。
7. 箇条書きの項目数が3の箇所を集める。
8. 段落ごとに文字数を数え、分散が小さい箇所を集める。
9. 各段落の最終文を集め、同じ形で終わっていないか確かめる。
10. 各文の文頭を集め、同じ語が繰り返されていないか確かめる。
