{ ... }:
let
  commonConfigs = [
    ../../common/cli/git
  ];

  nixDesktopConfigs = [
    ../../nixos/kwin-inputmethod.nix
  ];

  deviceConfigs = [
    ./devices/xremap.nix
  ];
in
{
  home.stateVersion = "25.11";
  imports =
    commonConfigs
    ++ nixDesktopConfigs
    ++ deviceConfigs
    ;
}
