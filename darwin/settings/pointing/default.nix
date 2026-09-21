{ ... }:
{
  imports = [
    ./mouse.nix
    ./trackpad.nix
  ];

  system.activationScripts.postActivation.text = ''
    defaults write NSGlobalDomain CGDisableCursorLocationMagnification -bool true
  '';
}
