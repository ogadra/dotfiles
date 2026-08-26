# 立場

書き手が何を引き受けているかを見る。

## 検出対象

### 反証できない主張

重要だ、深い、構造的だと言うが、何がどうしてそうなのかを書かない文。読み手が反論しようとしても、反論する対象がない。

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

何がどうしてそうなのかを書く。書けないなら、その文を削る。

### 結論の回避

すべての立場を紹介してどれも選ばない形。

#### AI版

```
REST、GraphQL、gRPCにはそれぞれ適した場面がある。要件とチームの習熟度によって最適な選択は変わる。

REST, GraphQL, and gRPC each suit different situations. The right choice depends on your requirements and your team's familiarity.
```

#### 修正版

```
RESTにした。クライアントが社内の2つだけで、スキーマの共有はOpenAPIで足りたからだ。

We went with REST. There are only two internal clients, and sharing an OpenAPI schema was enough.
```

#### 修正の型

選んだものを書く。選べないなら、その節ごと削る。

### 全方位肯定

比較や技術選定で、どれも肯定して終わる形。判断材料を出しているように読めるが、書き手は判断を放棄している。

#### AI版

```
Prismaは型安全で開発体験が良い。Drizzleは軽量でSQLに近い。TypeORMは実績が豊富だ。

Prisma is type-safe with a good developer experience. Drizzle is lightweight and close to SQL. TypeORM has a long track record.
```

#### 修正版

```
Drizzleにした。Prismaも試したが、生成物のサイズがLambdaのデプロイ上限に当たった。

We went with Drizzle. I tried Prisma too, but the generated client hit the Lambda deploy size limit.
```

#### 修正の型

「これを選んだ」「これは試して駄目だった」を引き受ける。引き受けないなら、その節は要らない。

### 弱い否定

やるなと言うべき場面で弱める形。

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

やるな、禁止されている、と言い切る。破綻する条件が分かっているなら、その条件を書く。

### 強度の振り切り

書き手が評価を両極端に振り、中間の温度を書かない形。実際の検証結果は「12分が3分になった」「誤差の範囲だった」「条件によって逆転した」になる。

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
    - 控えめに書く
- 本当に差が大きい場合
    - 強い言葉を使う

### 根拠のない強い評価

評価だけを置いて、その根拠を添えない形。

#### AI版

```
この実装は非常に堅牢で、運用面でも優れている。

This implementation is highly robust and operationally excellent.
```

#### 修正版

```
この実装は、ワーカーが落ちても未処理のジョブを取りこぼさない。3ヶ月動かして、再起動を12回挟んでも欠落は出ていない。

This implementation doesn't drop unprocessed jobs when a worker dies. It's been running three months across twelve restarts with no losses.
```

#### 修正の型

評価の直後に、そう言える根拠を1つ置く。置けないなら評価を削る。

### ヘッジの重ね掛け

1つの段落に保険を複数重ねる形。

#### AI版

```
おそらくこの方法が、少なくとも現時点では、一定の条件下では有効かもしれない。

This approach may perhaps be effective, at least for now, under certain conditions.
```

#### 修正版

```
この方法は、1日あたり10万件までのジョブで動くことを確認している。それを超える量は試していない。

I've confirmed this works up to a hundred thousand jobs a day. I haven't tried more than that.
```

#### 修正の型

保留したい範囲を、具体的な適用範囲として1回だけ書く。

### 儀式化した免責

各節の最後に保険文を置く形。

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

必要な保留は1つの文書に1回か2回まで。各節末に置かない。

## 検出手順

1. 断定を含む文を集め、それぞれについて「誰かが反論できるか」を確かめる。反論する対象が無いものが反証できない主張。
2. 評価語を含む文を集め、直後か直前に根拠があるか確かめる。
3. 段落ごとにヘッジの数を数える。2つ以上ある段落を指摘する。
4. 各節の最終段落を集め、保険文になっていないか確かめる。
5. 比較を含む節で、書き手が何を選んだかが書かれているか確かめる。
6. 禁止を伝える文を集め、否定が弱められていないか確かめる。
7. 極端な評価語を集め、数字に置き換えられるか確かめる。
