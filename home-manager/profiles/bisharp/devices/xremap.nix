{ ... }:
{
  # Device-specific modmaps; enable/keymap live in home-manager/nixos/xremap
  services.xremap.config.modmap = [
    {
      name = "internal-kbd-swap-capslock-ctrl";
      device.only = [ "AT Translated Set 2 keyboard" ];
      remap = {
        CAPSLOCK = "LEFTCTRL";
        LEFTCTRL = "CAPSLOCK";
      };
    }
    {
      name = "hhkb-swap-alt-super";
      device.only = [ "HHKB" ];
      remap = {
        LEFTALT = "LEFTMETA";
        LEFTMETA = "LEFTALT";
        RIGHTALT = "RIGHTMETA";
        RIGHTMETA = "RIGHTALT";
      };
    }
  ];
}
