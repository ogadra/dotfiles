{ pkgs, ... }:
{
  networking.hostName = "bisharp";
  imports = [
    ./hardware-configuration.nix
  ];
}
