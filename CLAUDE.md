# CLAUDE.md

## 概要

Nix Flakes + Home Managerで管理するdotfiles。これらのマシンで使うツールやアプリの設定は、このリポジトリに置く。

### マシンプロファイル

| ホスト名 | アーキテクチャ | OS | デスクトップ環境 |
|---|---|---|---|
| `bisharp` | x86_64-linux | NixOS | KDE Plasma 6 |
| `xurkitree` | x86_64-linux | NixOS | KDE Plasma 6 |
| `latias` | x86_64-darwin | macOS | - |
| `stakataka` | aarch64-darwin | macOS | - |

## 検証

- NixOSのプロファイル
    - `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel --no-link` で、switchせずに評価とビルドを行う
- flakeが参照するスクリプト
    - `nix eval` の前に `git add` でgitに載せる

## 依存の更新

- nixpkgsのrevは、コミット日から3日以上経ったものを採用する

## ファイルの置き場所

| 対象 | 置き場所 |
|---|---|
| マシンのシステム設定 | `profiles/<hostname>/` |
| マシンのHome Manager設定 | `home-manager/profiles/<hostname>/` |
| 新しいCLIツール | `home-manager/common/cli/<toolname>/default.nix` |
| 新しいGUIアプリ | `home-manager/common/apps/<category>/<appname>/` |
| Linux固有の設定 | `home-manager/nixos/` |

## Nixスクリプト

- `echo` を書いてよい場面
    - 別のコマンドへのパイプ
    - ファイル末尾への改行の追加

## コードスタイル

- 既存のコードに足すとき
    - 周りと同じ書き方にする
- スタイルを変えるとき
    - 既にあるコードも新しいスタイルに書き直す

## コメント

- 英語で書く
- 1行に収める
- 次のものを書く
    - その値を選んだ理由
    - 設定プロパティの効果
    - 取りうる値
    - 単位
    - 範囲
    - バージョンによる注意点
