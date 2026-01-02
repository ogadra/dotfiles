{ ... }:
{
  services.xremap = {
    enable     = true;
    watch      = true;
    yamlConfig = ''
      modmap:
        - name: internal-kbd-swap-capslock-ctrl
          device:
            only:
              - AT Translated Set 2 keyboard
          remap:
            CAPSLOCK: LEFTCTRL
            LEFTCTRL: CAPSLOCK

      keymap:
        - name: Default
          application:
            not: /org\.wezfurlong\.wezterm/
          remap:
            ALT-c: C-c
            ALT-f: C-f
            ALT-p: C-p
            ALT-s: C-s
            ALT-t: C-t
            ALT-v: C-v
            ALT-w: C-w
            ALT-x: C-x
            ALT-z: C-z

        - name: Emacs Like
          application:
            not: /org\.wezfurlong\.wezterm/
          remap:
            C-d: Delete
            C-h: BackSpace
            C-m: Enter
            C-k: [Shift-End, Delete]
            C-Shift-f: Shift-Right
            C-Shift-b: Shift-Left
            C-Shift-p: Shift-Up
            C-Shift-n: Shift-Down
            C-Shift-a: Shift-Home
            C-Shift-e: Shift-End
            C-Shift-y: Shift-Insert

        - name: Terminal
          application:
            only: /org\.wezfurlong\.wezterm/
          remap:
            ALT-c: C-Shift-c
            ALT-v: Shift-Insert
    '';
  };
}
