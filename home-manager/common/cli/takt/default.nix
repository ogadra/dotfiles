{ inputs, pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.packages = [ inputs.nix-takt.packages.${system}.default ];

  home.file.".takt/config.yaml".source = ./config.yaml;
}
