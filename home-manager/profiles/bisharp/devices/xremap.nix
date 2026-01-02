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
    '';
  };
}
