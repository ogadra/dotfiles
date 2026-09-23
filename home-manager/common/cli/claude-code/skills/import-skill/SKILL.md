---
name: import-skill
description: 外部のスキルをこのリポジトリにコピーして自分のスキルにする。ユーザーがスキルのURLやリポジトリ名を渡して「入れたい」「導入したい」と言ったとき、「上流を参照せずコピーしたい」と言ったとき、またはユーザーが `/import-skill` と打ったときに使う。Vendors an external Claude skill into this repository.
allowed-tools: Bash(curl:*), Bash(tar:*), Bash(mkdir:*), Bash(cp:*), Bash(ls:*), Bash(find:*), Bash(wc:*), Bash(gh api:*), Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(bash ~/.claude/skills/readable-writing/scripts/review.sh:*), Read, Write, Edit
---

# Import Skill

上流のスキルを `home-manager/common/cli/claude-code/skills/<name>/` にコピーし、このリポジトリのファイルとして持つ。

## 手順

### 1. 取得

`git clone` はhookが止めるので、tarballを落とす。

```bash
curl -sSL https://codeload.github.com/<owner>/<repo>/tar.gz/refs/heads/<branch> | tar xz -C <tmpdir> --strip-components=1
```

取り込み元のコミットを控えてREADMEに書く。

```bash
gh api repos/<owner>/<repo>/commits/<branch> --jq '.sha[0:7] + " " + .commit.committer.date[0:10]'
```

### 2. ライセンスの確認

上流の `LICENSE` を読む。

- 取り込めるライセンス
    - MIT
    - Apache-2.0
    - BSD
    - 著作権表示とライセンス全文を同梱する
- ユーザーに判断を仰ぐライセンス
    - GPL
    - AGPL
    - LGPL
- `LICENSE` がない
    - 取り込めない
    - ユーザーに伝えて止める

### 3. 取り込む範囲を決める

Claude Codeに効くものだけ取る。上流はプラグインとして配布されていることが多く、`SKILL.md` が配布機構や他のエージェント向けの分岐を参照している。取らなかった部分への参照が `SKILL.md` に残るので、そこを探してREADMEに書く。

- `SKILL.md`
- スキルが読むファイル
    - ポリシー
    - プロンプト
    - スクリプト
- `LICENSE`

### 4. 配置

```
home-manager/common/cli/claude-code/skills/<name>/
├── SKILL.md
├── LICENSE     上流のまま置く。著作権行を書き換えない
└── README.md
```

READMEに書くもの。

- 何をするスキルか
- 由来
    - 上流のURL
    - ライセンス
    - 取り込み元のコミットと日付
- 上流から変えたところ
- 直すときに触るファイルと節

### 5. Nixに繋ぐ

`home-manager/common/cli/claude-code/default.nix` の `home.file` に1行足す。

```nix
".claude/skills/<name>".source = ./skills/<name>;
```

- ディレクトリごと渡す
- アルファベット順の位置に入れる

### 6. gitに見せる

```bash
git add -N home-manager/common/cli/claude-code/skills/<name>
```

flakesの対象はgit管理下のファイルだけなので、先にこれを実行する。

### 7. 文章を直す

READMEと、書き換えた `SKILL.md` に `/readable-writing` をかける。

frontmatterの `description` は上流のまま残す。Claudeがそのスキルを起動するか判断するときに読む文字列で、書き換えると起動条件を変えてしまう。`Do NOT use for ...` のような除外条件も残す。

### 8. コミット

2つに分ける。

1. 取り込み
2. 文章の修正

PRは `/pr-create` で作る。
