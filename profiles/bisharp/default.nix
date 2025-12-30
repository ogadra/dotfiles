{ pkgs, ... }:
let
  # Desktop
  desktopSettings = [
    ../../nixos/settings/desktop/fonts.nix
    ../../nixos/settings/desktop/i18n.nix
  ];
in
{
  networking.hostName = "bisharp";
  imports = [
    ./hardware-configuration.nix
  ]
  ++ desktopSettings;
}
