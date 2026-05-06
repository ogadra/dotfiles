# dotfiles

[Nix Flakes](https://nixos.wiki/wiki/Flakes) + [Home Manager](https://github.com/nix-community/home-manager) で管理

## マシン構成

| ホスト名 | OS | アーキテクチャ |
|---|---|---|
| `bisharp` | NixOS (KDE Plasma 6) | x86_64-linux |
| `latias` | macOS (nix-darwin) | x86_64-darwin |
| `stakataka` | macOS (nix-darwin) | aarch64-darwin |

## セットアップ

```bash
# 適用
make switch

# flake入力を全て更新
make update

# 特定の入力のみ更新 (例: claude-code)
make update claude-code-overlay
```

## ディレクトリ構成

```
.
├── flake.nix                # エントリポイント
├── nixos/                   # NixOS システム設定
├── darwin/                  # macOS システム設定
├── profiles/                # マシン固有のシステムプロファイル
├── home-manager/            # ユーザー環境設定
│   ├── common/              # クロスプラットフォーム
│   │   ├── apps/            # GUI (wezterm, vscode, etc.)
│   │   └── cli/             # CLI (fish, git, starship, etc.)
│   ├── nixos/               # Linux 固有 (kwin, wofi, etc.)
│   └── profiles/            # マシン固有のユーザープロファイル
├── private_dot_config/      # chezmoi管理 (レガシー)
├── data/                    # 設定データ
└── init/                    # 初期化スクリプト (レガシー)
```
