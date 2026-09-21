{ ... }:
{
  imports = [
    ./mouse.nix
    ./trackpad.nix
  ];

  system.activationScripts.postActivation.text = ''
    # Magnify the cursor when it is shaken
    defaults write NSGlobalDomain CGDisableCursorLocationMagnification -bool true
  '';
}
