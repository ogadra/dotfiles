---
name: cascade-merge
description: 連なったPRで、上流のブランチの変更を下流のブランチへ順にマージする。stacked PRを更新するとき、親ブランチの変更を下流のブランチすべてに反映するとき、またはユーザーが「cascade merge」「下流に反映して」「依存ブランチを更新して」と言ったときに使う。Cascade merges changes through a chain of dependent branches.
allowed-tools: Bash(gh pr list:*), Bash(jq:*), Bash(git checkout:*), Bash(git switch:*), Bash(git merge:*), Bash(git push origin:*), Bash(git status:*), Bash(git branch:*), Bash(git fetch:*)
---

# Cascade Merge

起点のブランチの変更を、PRの連なりにある下流のブランチすべてへ順に反映する。

## どのPRで直すか

上流のPRで足したもののやり方を変えるときは、上流のPRで直し、上流のPRのブランチを下流へcascade mergeする。

下流のPRでは、上流のPRで足したものに次のことをしない。

- 削除
- 移動
- 値の変更

## 手順

### 1. 下流のブランチを洗い出す

```bash
gh pr list --state open --json number,title,headRefName,baseRefName --limit 50 | jq -r '.[] | "\(.baseRefName)\t\(.headRefName)"'
```

`baseRefName` が今のブランチと一致するPRを探し、そのPRのブランチをbaseにするPRを再帰的にたどって連なりを組む。

### 2. ブランチごとにマージしてpushする

先にfetchし、下流のブランチを上から順に処理する。

```bash
git fetch origin
git checkout <downstream-branch>
git merge origin/<upstream-branch> --no-edit
git push origin <downstream-branch>
```

- マージ元
    - `origin/<upstream-branch>`
    - ローカルのブランチは使わない
    - hookは、PRのbaseのリモート追跡ブランチからの `git merge` だけを許す
- 上流のブランチのpush
    - `origin/<upstream-branch>` が更新される
    - 次の下流のマージより前に済ませる

下流のブランチへcherry-pickしない。マージがブロックされたときや、必要なコミットが1つだけのときも同じ。

- cherry-pickしたコミット
    - 新しいハッシュになる
    - gitは上流のコミットと同じ変更だと判別できない
    - 上流で変更するたびに手で拾い直すことになる
    - 拾い直すたびに、下流の履歴に重複したコミットとコンフリクトが残る
- hookによるブロック
    - 対象
        - default branch以外をbaseにするPR
    - ブロックするもの
        - 上流のブランチが既に持つコミットの `git cherry-pick`
    - 上流のブランチ
        - base
        - baseのPRのbaseを連なりの上までたどったもの
        - default branch

必要なマージがブロックされたら、別の手段を探さずにユーザーへ報告する。

### 3. コンフリクトに対処する

マージでコンフリクトが起きたら、次の順に進める。

1. ユーザーにコンフリクトを報告する
2. 進め方をユーザーに聞く
    - 手で解決する
    - そのブランチを飛ばす
    - 中止する

## 例

次のPRの連なりがあるとする。

```
main
 └── feature-1
      └── feature-2
           └── feature-3
```

`feature-1` を更新したとき、cascade mergeは次のことをする。

1. `feature-1` を `feature-2` へマージしてpushする
2. `feature-2` を `feature-3` へマージしてpushする

## 出力

結果を表で報告する。

| Branch | Merged From | Status |
|--------|-------------|--------|
| feature-2 | feature-1 | Done |
| feature-3 | feature-2 | Done |
