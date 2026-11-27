{
  config,
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

  # Hardware
  hardwareSettings = [
    ../../nixos/settings/hardware/audio.nix
    ../../nixos/settings/hardware/thunderbolt.nix
  ];

  # Network
  networkSettings = [
    ../../nixos/settings/network/arp.nix
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
  networking.hostName = "bisharp";

  system.activationScripts.nix-gc.text = ''
    ${config.nix.package}/bin/nix-collect-garbage --delete-older-than 3d
  '';

  imports = [
    ./hardware-configuration.nix
  ]
  ++ desktopSettings
  ++ hardwareSettings
  ++ networkSettings
  ++ nixLdSettings
  ++ powerSettings
  ++ programsSettings
  ++ shellSettings
  ++ virtualizationSettings;

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
