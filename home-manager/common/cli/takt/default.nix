{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.nix-takt.packages.${pkgs.system}.default ];
}
