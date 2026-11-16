---
name: keybind
description: キーバインドを足す、変える、消す。ユーザーが「キーバインドを追加して」「ショートカットを変えたい」「このキーが効かない」と言ったとき、wezterm・herdr・xremap・Karabiner・KDE・macOSのショートカットを変えるとき、またはユーザーが `/keybind` と打ったときに使う。Chooses keybinds that work on every host and keyboard, and fixes them only after the user agrees.
---

# Keybind

## 原則

- どのマシンでも、どのキーボードでも、同じキーバインドで同じ操作ができるようにする
- キーはユーザーの同意を得てから確定する

## 手順

### 1. 候補を出す

- 候補ごとに、LinuxとmacOSで物理的に同じ位置のキーを書く
    - weztermの `keybinds.nix` の対応
        - `mod`
            - Linux: `ALT`
            - macOS: `SUPER`（Cmd）
        - `option`
            - Linux: `SUPER`
            - macOS: `ALT`（Option）
        - `CTRL`
            - 両方で `CTRL`
    - キーボードごとの入れ替え
        - Linux: `home-manager/profiles/<hostname>/devices/xremap.nix`
        - macOS: `home-manager/common/apps/karabiner/default.nix`
- 候補は2〜4個出す

### 2. 押せるかを確かめる

- 分かっている制限
    - bisharpの内蔵キーボード（ThinkPad P14s Gen 6、`AT Translated Set 2 keyboard`）
        - CapsLock位置のCtrl + Shift + X
            - Xが届かない
            - キーボードのコントローラがXの代わりに `0xFF`（key detection error）を返す
            - 設定でもファームウェアでも直せない
        - CapsLock位置のCtrl + Shift + ほかの英字・`Space`・`[`
            - 届く
        - Alt + Shift + X、Super + Shift + X
            - 届く
- 制限が分かっていない組み合わせ
    - bisharpで実測する
        - `scripts/keylog.py` でxremapの出力デバイスを記録する
            ```bash
            python3 -I .claude/skills/keybind/scripts/keylog.py 60
            ```
        - 記録を始めてから、ユーザーに押してもらう
            - デスクトップの壁紙をクリックしてフォーカスを外してから押す
                - weztermやブラウザでは `Ctrl+C` などが効いてしまう
            - xremapはwezterm以外でEmacs風の置き換えをする
                - 記録に別のキーが出ても、キーボードから届いたものとして読む
    - macOSでは実測していない
        - 実測できないことをユーザーに伝える

### 3. ほかの割り当てと衝突しないかを確かめる

候補ごとに、次をすべて確かめる。

- 端末
    - wezterm: `home-manager/common/apps/terminal/wezterm/keybinds.nix`
    - herdr: `home-manager/common/cli/herdr/default.nix` の `keys`
        - weztermが先に受け取るキーは、herdrには届かない
- Linux
    - xremap: `home-manager/nixos/xremap/default.nix`
        - wezterm以外のアプリで効く
    - KDE: `home-manager/nixos/kwin/shortcuts/`
    - KDEの実機の設定: `~/.config/kglobalshortcutsrc`
        - Nixで管理していないアプリの既定値も入る
            - 例: 1Passwordの `Ctrl+Shift+Space`
- macOS
    - システム: `darwin/settings/symbolichotkeys.nix`
        - 書いていないidは、macOSの既定値で有効になる
    - Karabiner: `home-manager/common/apps/karabiner/default.nix`
        - Emacs風の割り当ては、weztermを対象から外している
    - macSKK
        - 上書き: `home-manager/common/apps/macskk/keyBindingSets.plist`
        - 既定値: macSKKのソースの `macSKK/KeyBinding.swift`
        - weztermの `macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'`
            - Ctrl か Shift を含むキーは、weztermより先にmacSKKに渡る
    - Raycast: `home-manager/common/apps/raycast/default.nix`
    - AltTab: `home-manager/common/apps/alt-tab/default.nix`
- 似たキーとの押し間違い
    - Shiftの有無だけで別の操作になるキーがないか

### 4. ユーザーに選んでもらう

- AskUserQuestionで聞く
    - 候補ごとに書く
        - LinuxとmacOSのキー
        - 押せるかの確認結果
        - 衝突の確認結果
- ユーザーが選ぶまで、キーを確定しない

### 5. 変えたあとに確かめる

- `nix eval` で、OSごとに展開された設定を確かめる
    ```bash
    nix eval --raw '.#nixosConfigurations.bisharp.config.home-manager.users.ogadra.xdg.configFile."wezterm/keybinds.lua".text'
    nix eval --raw '.#darwinConfigurations.stakataka.config.home-manager.users.ogadra.xdg.configFile."wezterm/keybinds.lua".text'
    ```
