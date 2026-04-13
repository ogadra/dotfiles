{ ... }:
{
  imports = [
    ./mouse.nix
    ./trackpad.nix
  ];

  system.defaults.NSGlobalDomain = {
    # カーソルを振った時に拡大する機能を無効化
    CGDisableCursorLocationMagnification = true;
  };
}
