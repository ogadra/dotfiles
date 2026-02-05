{ ... }:
let
  # GUI Applications (cross-platform)
  appConfigs = [
    ../../common/apps/editor
    ../../common/apps/terminal
  ];

  # CLI tools (cross-platform)
  commonConfigs = [
    ../../common/cli/direnv
    ../../common/cli/git
    ../../common/cli/gh
    ../../common/cli/ghq
    ../../common/cli/gnumake
    ../../common/cli/claude-code
    ../../common/cli/fish
    ../../common/cli/fzf
    ../../common/cli/mpv
    ../../common/cli/starship
  ];
in
{
  home.stateVersion = "25.11";
  imports =
    appConfigs
    ++ commonConfigs
    ;
}
