{ ... }:
{
  # Device-specific modmaps; enable/keymap live in home-manager/nixos/xremap
  services.xremap.config.modmap = [
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
