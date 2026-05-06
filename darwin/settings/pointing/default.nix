{ ... }:
{
  imports = [
    ./mouse.nix
    ./trackpad.nix
  ];

  system.activationScripts.postActivation.text = ''
    # カーソルを振った時に拡大する機能を無効化
    defaults write NSGlobalDomain CGDisableCursorLocationMagnification -bool true
  '';
}
