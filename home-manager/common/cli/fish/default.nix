{ ... }:
{
  imports = [
    ./conf.d/aliases.nix
    ./conf.d/functions.nix
    ./theme.nix
  ];

  programs.fish = {
    enable = true;
  };
}
