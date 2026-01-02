{ ... }:
let
  appConfigs = [
    ../../common/apps/editor
  ];

  commonConfigs = [
    ../../common/cli/git
    ../../common/cli/ghq
    ../../common/cli/claude-code
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
    appConfigs
    ++ commonConfigs
    ++ nixDesktopConfigs
    ++ deviceConfigs
    ;
}
