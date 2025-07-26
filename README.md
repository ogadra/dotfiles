# dotfiles

[chezmoi](https://www.chezmoi.io/)を使用して管理

## 必要なもの

- [chezmoi](https://www.chezmoi.io/)
- git

## インストール

```bash
# chezmoiのインストール
brew install chezmoi

# dotfilesの初期化とインストール
chezmoi init --apply ogadra
```

## 使い方

```bash
# 変更を確認
chezmoi diff

# 設定を適用
chezmoi apply

# テンプレートファイルを編集
chezmoi edit <ファイルパス>

# 変更をリポジトリに追加
chezmoi add <ファイルパス>
```

## 設定のカスタマイズ

設定は`data/`ディレクトリ内の各種YAMLファイルに記載。

`data/`ディレクトリ内の`.sample`ファイルを参考にして設定。
