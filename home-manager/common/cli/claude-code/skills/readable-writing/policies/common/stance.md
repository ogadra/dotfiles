# 立場

書き手が何を引き受けているかを見る。

## 検出対象

### 反証できない主張

重要だ、深い、構造的だとだけあって、何がどうしてそうなのかが無い文。

#### AI版

```
この設計判断は、システム全体のアーキテクチャに対して本質的な意味を持つ。

This design decision is fundamentally significant for the architecture of the whole system.
```

#### 修正版

```
キューを挟んだので、ワーカーを落としても未処理のジョブが消えない。

Putting a queue in front means jobs survive a worker restart.
```

#### 修正の型

- 何がどうしてそうなのかを書く
- 書けない場合
    - その文を削る

### 結論の回避

すべての立場を紹介して、どれも選ばない。比較や技術選定でどれも肯定して終わる形も含む。

#### AI版

```
REST、GraphQL、gRPCにはそれぞれ適した場面がある。要件とチームの習熟度によって最適な選択は変わる。

REST, GraphQL, and gRPC each suit different situations. The right choice depends on your requirements and your team's familiarity.
```

```
Prismaは型安全で開発体験が良い。Drizzleは軽量でSQLに近い。TypeORMは実績が豊富だ。

Prisma is type-safe with a good developer experience. Drizzle is lightweight and close to SQL. TypeORM has a long track record.
```

#### 修正版

```
RESTにした。クライアントが社内の2つだけで、スキーマの共有はOpenAPIで足りたからだ。

We went with REST. There are only two internal clients, and sharing an OpenAPI schema was enough.
```

```
Drizzleにした。Prismaも試したが、生成物のサイズがLambdaのデプロイ上限に当たった。

We went with Drizzle. I tried Prisma too, but the generated client hit the Lambda deploy size limit.
```

#### 修正の型

- 選んだものを書く
- 試して駄目だったもの
    - 駄目だったと書く
- どちらも書けない場合
    - その節ごと削る

### 弱い否定

#### AI版

```
本番環境で直接マイグレーションを実行するのは、あまり推奨されません。

Running migrations directly against production is generally not recommended.
```

#### 修正版

```
本番環境で直接マイグレーションを実行しない。

Don't run migrations directly against production.
```

#### 修正の型

- やるな、と言い切る
- 破綻する条件が分かっている場合
    - その条件を書く

### 強度の振り切り

評価を両極端に振り、中間の温度を書かない。実際の検証結果はこうなる。

- `12分が3分になった`
- `誤差の範囲だった`
- `条件によって逆転した`

#### AI版

```
キャッシュを挟んだことで、ビルド時間が劇的に改善した。

Caching led to a dramatic improvement in build times.
```

#### 修正版

```
キャッシュを挟んだら、初回ビルドが9分から3分になった。2回目以降は元から30秒だった。

Caching took the first build from nine minutes to three. Later builds were already thirty seconds.
```

#### 修正の型

- 数字を出せる場合
    - 数字で書く
- 数字を出せない場合
    - 確かめた結果をそのまま書く

### 裏を取らない伝聞

次のものがこの形になりやすい。

- 上流の変更
- リリース日
- 対応状況
- 仕様

#### AI版

```
KDEはKWin 6.7で `org_kde_kwin_blur` を外したらしい。weztermは後継のプロトコルにまだ対応していないようだ。

KDE seems to have dropped `org_kde_kwin_blur` in KWin 6.7. wezterm reportedly does not speak its replacement yet.
```

#### 修正版

```
KDEの開発者はKWin 6.7で `org_kde_kwin_blur` を外し、`ext_background_effect_manager_v1` を入れた。weztermの開発者はPR #7615でこの新プロトコルに対応した。

KDE dropped `org_kde_kwin_blur` in KWin 6.7 and added `ext_background_effect_manager_v1`. wezterm picked up the new protocol in PR #7615.
```

#### 修正の型

伝聞の語を見つけたら、まず出典を当たる。

- 当たれる
    - 調べて断定で書く
    - 出典をどれか1つ添える
        - コミット
        - PR番号
        - リリース
        - 仕様書
- 当たれない
    - 誰から聞いたかを書く
- 当たったが決まらない
    - その記述ごと削る

### ヘッジの重ね掛け

保険とは、書き手が事実の出所を示さずに引き受ける範囲を狭めるときに使う語。

#### AI版

```
おそらくこの方法が、少なくとも現時点では、一定の条件下では有効かもしれない。

This approach may perhaps be effective, at least for now, under certain conditions.
```

#### 修正版

```
この方法は、1日あたり10万件までのジョブで動くことを確認している。

I've confirmed this works up to a hundred thousand jobs a day.
```

#### 修正の型

- 確かめた範囲を、具体的な適用範囲として1回だけ書く
- 適用範囲が読み手の判断を変えない場合
    - その節ごと消す

### 儀式化した免責

#### AI版

```
## キャッシュ

初回ビルドが9分から3分になった。なお、効果は環境によって異なる。

## リトライ

3回まで再送する。なお、最適な回数はワークロードによって異なる。

## Caching

The first build went from nine minutes to three. Note that results vary by environment.

## Retries

We retry up to three times. Note that the right number depends on your workload.
```

#### 修正版

```
## キャッシュ

初回ビルドが9分から3分になった。

## リトライ

3回まで再送する。この回数は1日10万件のジョブで決めた。

## Caching

The first build went from nine minutes to three.

## Retries

We retry up to three times. I picked that from a workload of a hundred thousand jobs a day.
```

#### 修正の型

- 免責の文を削る
- 数字を決めた根拠がある場合
    - 「この回数は1日10万件のジョブで決めた」のように根拠に置き換える
- 必要な保留は1つの文書に1回か2回まで

## 検出手順

1. 断定を含む文を集める
    - 誰かが反論できるか確かめる
    - 反論する対象が無いものが反証できない主張
2. 段落ごとに、引き受ける範囲を狭める語の数を数える
    - 2つ以上ある段落を指摘する
3. 各節の最終段落を集める
    - 保険文になっていないか確かめる
4. 比較を含む節で、何を選んだかを書いているか確かめる
5. 禁止を伝える文の否定が弱まっていないか確かめる
6. 極端な評価語を数字に置き換えられるか試す
7. 伝聞の語を含む文を集める
    - 述べている事実に出典があるか確かめる
    - 出典に当たれるものを指摘する
