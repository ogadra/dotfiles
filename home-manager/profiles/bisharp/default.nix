{ ... }:
let
  commonConfigs = [
    ../../common/cli/git
  ];
in
{
  home.stateVersion = "25.11";
  imports = commonConfigs;
}
