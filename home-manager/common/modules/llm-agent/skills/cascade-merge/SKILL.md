---
name: cascade-merge
description: PRのチェーンで、上流のブランチの変更を下流のブランチへ順にマージする。stacked PRを更新するとき、親ブランチの変更を下流のブランチすべてに反映するとき、またはユーザーが「cascade merge」「下流に反映して」「依存ブランチを更新して」と言ったときに使う。Cascade merges changes through a chain of dependent branches.
allowed-tools: Bash(gh pr list:*), Bash(jq:*), Bash(git checkout:*), Bash(git switch:*), Bash(git merge:*), Bash(git push origin:*), Bash(git status:*), Bash(git branch:*), Bash(git fetch:*)
---

# Cascade Merge

起点のブランチの変更をPRのチェーンの下流にあるブランチすべてへ順にマージする。

## どのPRで直すか

上流のPRで足したものに次の変更を加えるときは、上流のPRで直し、上流のブランチを下流へcascade mergeする。

- 削除
- 移動
- 値の変更

## 手順

### 1. 下流のブランチを洗い出す

```bash
gh pr list --state open --json number,title,headRefName,baseRefName --limit 50 | jq -r '.[] | "\(.baseRefName)\t\(.headRefName)"'
```

`baseRefName` が起点のブランチと一致するPRを探す。見つかったPRのブランチをbaseにするPRを再帰的にたどり、チェーンを組む。

### 2. ブランチごとにマージしてpushする

先にfetchし、下流のブランチを上から順に処理する。

```bash
git fetch origin
git checkout <downstream-branch>
git merge origin/<upstream-branch> --no-edit
git push origin <downstream-branch>
```

- マージ元には `origin/<upstream-branch>` を指定する
    - hookが通す `git merge` はPRのbaseのリモート追跡ブランチからのものだけ
- 次の下流のブランチをマージする前に、上流のブランチをpushして `origin/<upstream-branch>` を更新する

マージがブロックされたときも、必要なコミットが1つだけのときも、下流のブランチへcherry-pickしない。cherry-pickしたコミットは新しいハッシュを持つので、gitは上流のコミットと同じ変更だと判別できない。上流を変更するたびに同じコミットを手でcherry-pickし直すことになり、そのたびに下流の履歴へ重複したコミットが増え、コンフリクトが起きる。

default branch以外をbaseにするPRでは、上流のブランチが持つコミットの `git cherry-pick` をhookが止める。上流のブランチは、baseからPRのbaseをdefault branchまでたどった先のブランチすべてを指す。

マージがブロックされたら、別の手段を探さずにユーザーへ報告する。

### 3. コンフリクトに対処する

1. ユーザーにコンフリクトを報告する
2. 進め方をユーザーに聞く
    - 手で解決する
    - そのブランチを飛ばす
    - 中止する

## 例

次のPRのチェーンがあるとする。

```
main
 └── feature-1
      └── feature-2
           └── feature-3
```

`feature-1` を更新したら、次の順にマージしてpushする。

1. `feature-1` を `feature-2` へマージしてpushする
2. `feature-2` を `feature-3` へマージしてpushする

## 出力

結果を表で報告する。

| Branch | Merged From | Status |
|--------|-------------|--------|
| feature-2 | feature-1 | Done |
| feature-3 | feature-2 | Done |
