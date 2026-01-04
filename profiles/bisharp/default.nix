{
  inputs,
  pkgs,
  username,
  ...
}:
let
  # Desktop
  desktopSettings = [
    ../../nixos/settings/desktop/fonts.nix
    ../../nixos/settings/desktop/i18n.nix
  ];

  # Shell
  shellSettings = [
    ../../nixos/settings/shell/fish.nix
  ];

  # Nix-ld
  nixLdSettings = [
    ../../nixos/settings/nix-ld/default.nix
  ];
in
{
  networking.hostName = "bisharp";

  imports = [
    ./hardware-configuration.nix
  ]
  ++ desktopSettings
  ++ shellSettings
  ++ nixLdSettings;

  home-manager.sharedModules = [
    inputs.xremap.homeManagerModules.default
  ];
  home-manager.users.${username} = import ../../home-manager/profiles/bisharp;

  # TODO: split file for xremap settings
  hardware.uinput.enable = true;
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660", TAG+="uaccess"
    KERNEL=="event*", NAME="input/%k", MODE="660", GROUP="input"
  '';

  users.users.${username}.extraGroups = [
    "input"
    "uinput"
  ];
}
