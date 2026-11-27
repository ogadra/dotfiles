---
name: keybind
description: キーバインドを足す、変える、消す。ユーザーが「キーバインドを追加して」「ショートカットを変えたい」「このキーが効かない」と言ったとき、wezterm・herdr・xremap・Karabiner・KDE・macOSのショートカットを変えるとき、またはユーザーが `/keybind` と打ったときに使う。Chooses keybinds that work on every host and keyboard, and fixes them only after the user agrees.
---

# Keybind

## 原則

- 同じキーバインドで同じ操作ができるようにする
    - どのマシンでも
    - どのキーボードでも
- キーはユーザーの同意を得てから確定する

## 手順

### 1. 候補を出す

- 2〜4個出す
- 既にある慣習を検討して選ぶ
    - Emacsの標準のキーバインド
    - ほかのツールの設定の慣習
        - 端末
            - kitty
            - Alacritty
        - herdr
            - tmux
- 各案に、LinuxとmacOSで物理的に同じ位置のキーを書く
    - weztermの `keybinds.nix` の対応
        - `mod`
            - Linuxでは `ALT`
            - macOSではCmdキーの `SUPER`
        - `option`
            - Linuxでは `SUPER`
            - macOSではOptionキーの `ALT`
        - `CTRL`
            - 両方で `CTRL`
    - キーボードごとの入れ替え
        - Linux
            - `home-manager/profiles/<hostname>/devices/xremap.nix`
        - macOS
            - `home-manager/common/apps/karabiner/default.nix`

### 2. 押せないキーを避ける

- bisharpの内蔵キーボードで、CapsLock位置のCtrl + Shift + X

### 3. ほかの割り当てと衝突しないかを確かめる

- 端末
    - wezterm
        - `home-manager/common/apps/terminal/wezterm/keybinds.nix`
    - herdr
        - `home-manager/common/cli/herdr/default.nix` の `keys`
            - weztermが先に受け取るキーは、herdrには届かない
- Linux
    - xremap
        - `home-manager/nixos/xremap/default.nix`
            - wezterm以外のアプリで効く
    - KDE
        - `home-manager/nixos/kwin/shortcuts/`
        - 実機の `~/.config/kglobalshortcutsrc`
            - Nixで管理していないアプリの既定値も入る
                - 1Passwordの `Ctrl+Shift+Space` など
- macOS
    - システム
        - `darwin/settings/symbolichotkeys.nix`
            - 書いていないidは、macOSの既定値で有効になる
    - Karabiner
        - `home-manager/common/apps/karabiner/default.nix`
            - Emacs風の割り当ては、wezterm以外のアプリで効く
    - macSKK
        - 上書き
            - `home-manager/common/apps/macskk/keyBindingSets.plist`
        - 既定値
            - macSKKのソースの `macSKK/KeyBinding.swift`
        - weztermの `macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'`
            - CtrlかShiftを含むキーは、weztermより先にmacSKKに渡る
    - Raycast
        - 実機のSettings → Extensions
            - hotkeyは暗号化DBにあり、Nixでは管理していない
    - AltTab
        - `home-manager/common/apps/alt-tab/default.nix`

### 4. ユーザーに選んでもらう

- AskUserQuestionで聞く
    - 選択肢ごとに書く
        - Linuxのキー
        - macOSのキー
        - 押せるかの確認結果
        - 衝突の確認結果
