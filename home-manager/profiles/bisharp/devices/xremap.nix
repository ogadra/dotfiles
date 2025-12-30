{ ... }:
{
  services.xremap = {
    enable      = true;
    watch       = true;
    extraArgs   = [
      "--device"
      "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
    ];
    yamlConfig  = ''
      modmap:
        - name: internal-kbd-switch-capslock-ctrl
          remap:
            CAPSLOCK: LEFTCTRL
            LEFTCTRL: CAPSLOCK
    '';
  };
}
