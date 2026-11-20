# 立場

## パターン

### 反証できない主張

書き手が `重要だ` `深い` `構造的だ` と言うだけで、何がどうしてそうなのかを書いていない。

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

- 何がどうしてそうなのかを書ける場合
    - 書く
- 書けない場合
    - その文を削る

### 結論の回避

立場や比較対象を一通り紹介して終える。

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

- 選んだものがある場合
    - 選んだものを書く
- 試して駄目だったものがある場合
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

- 何が起きるか分からない場合
    - やるな、と言い切る
- 何がどの条件でどうなるか分かっている場合
    - その条件を書く

### 極端な評価語

`劇的に` のような極端な評価語を書き、確かめた結果を書いていない。

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
        - `誤差の範囲だった`
        - `条件によって逆転した`

### 裏を取らない伝聞

次の話題は伝聞で書きやすい。

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

伝聞の語を見つけたら、まず出典に当たる。

- 当たれる
    - 調べて断定で書く
    - 出典をどれか1つ添える
        - コミット
        - PR番号
        - リリース
        - 仕様書
- 当たれない
    - 誰から聞いたかを書く
- 当たったが出典が見つからない
    - その記述ごと削る

### ヘッジ

言い切る範囲を狭める語を一文に重ねて置いている。

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

- 確かめた範囲がある場合
    - 具体的な適用範囲として1回だけ書く
- 適用範囲を書いても読み手が同じ判断をする場合
    - その節ごと削る

### 決まり文句の免責

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

- 数字を決めた根拠がある場合
    - 免責の文を根拠に置き換える
        - `この回数は1日10万件のジョブで決めた`
- 根拠が無い場合
    - 免責の文を削る

### 変更報告の取り違え

変更を報告する文で、済んだことと予定、確かめたことと確かめていないことを区別せずに書く。

- 済んだ変更を予定の形で書く
- 前からある動作を今回変えたことのように書く
- 確かめていないことを確かめたように書く

#### AI版

```
リトライ回数を5回に変更します。タイムアウト時は例外を返します。テストで動作を確認しました。

This PR will change the retry count to five. On timeout it returns an exception. Verified with tests.
```

#### 修正版

```
リトライ回数を3回から5回に変えた。タイムアウトしたときに例外を返す動作は変えていない。ユニットテストは通したが、ステージングでは試していない。

Changed the retry count from three to five. Timeouts still return an exception, as before. Unit tests pass; I haven't tried it on staging.
```

#### 修正の型

- 済んだ変更
    - 過去形で書く
- 前からある動作
    - 今の状態として書く
    - 今回の変更とは別の文にする
- 確かめたこと
    - 何で確かめたかを書く
- 確かめていないこと
    - 確かめていないと書く

## 検出手順

1. 断定を含む文を集める
    - 反証できるか確かめる
        - 反証する対象が無い文を指摘する
2. 段落ごとに言い切る範囲を狭める語の数を数える
    - 2つ以上ある段落を指摘する
3. 各節の最終段落を集める
    - 免責の文を拾う
4. 比較を含む節で何を選んだかを書いているか見る
5. 書き手が否定を弱めて書いた禁止の文を集める
6. 極端な評価語を数字に置き換えられるか試す
7. 伝聞の語を含む文を集める
    - 伝聞で書きやすい話題の文から先に見る
    - 述べた事実の出典を探す
    - 出典に当たれるものを指摘する
8. 変更を報告する文を集める
    - 済んだ変更を予定の形で書いていないか確かめる
    - 書き手が確かめたと書いた文に、確かめた手段があるか見る
