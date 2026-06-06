{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.nix-takt.packages.${pkgs.system}.default ];

  home.file.".takt/config.yaml".source = ./config.yaml;
}
