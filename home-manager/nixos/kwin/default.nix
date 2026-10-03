{ inputs, ... }:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./inputmethod.nix
    ./powerdevil.nix
    ./settings.nix
    ./shortcuts
  ];

  programs.plasma.enable = true;
}
