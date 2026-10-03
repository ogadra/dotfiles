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

  # Hardware; bisharp's audio.nix and thunderbolt.nix are ThinkPad-specific, so a desktop skips them
  hardwareSettings = [
  ];

  # Nix-ld
  nixLdSettings = [
    ../../nixos/settings/nix-ld/default.nix
  ];

  # Power
  powerSettings = [
    ../../nixos/settings/power
  ];

  # Programs
  programsSettings = [
    ../../nixos/settings/programs/1password.nix
    ../../nixos/settings/programs/steam.nix
  ];

  # Shell
  shellSettings = [
    ../../nixos/settings/shell/fish.nix
    ../../nixos/settings/shell/zsh.nix
  ];

  # Virtualization
  virtualizationSettings = [
    ../../nixos/settings/virtualization/docker.nix
  ];
in
{
  networking.hostName = "xurkitree";

  services.openssh.enable = true;

  imports = [
    ./hardware-configuration.nix
  ]
  ++ desktopSettings
  ++ hardwareSettings
  ++ nixLdSettings
  ++ powerSettings
  ++ programsSettings
  ++ shellSettings
  ++ virtualizationSettings;

  home-manager.sharedModules = [
    inputs.xremap.homeManagerModules.default
  ];
  home-manager.users.${username} = import ../../home-manager/profiles/xurkitree;

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
