{ pkgs, ... }:
let
  # Desktop
  desktopSettings = [
    ../../nixos/settings/desktop/fonts.nix
  ];
in
{
  networking.hostName = "bisharp";
  imports = [
    ./hardware-configuration.nix
  ]
  ++ desktopSettings;
}
