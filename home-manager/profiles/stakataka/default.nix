{ ... }:
let
  # GUI Applications (cross-platform)
  appConfigs = [
    ../../common/apps/1password
    ../../common/apps/alt-tab
    ../../common/apps/editor
    ../../common/apps/karabiner
    ../../common/apps/terminal
  ];

  # CLI tools (cross-platform)
  commonConfigs = [
    ../../common/cli/direnv
    ../../common/cli/git
    ../../common/cli/gh
    ../../common/cli/ghq
    ../../common/cli/gnumake
    ../../common/cli/gomi
    ../../common/cli/claude-code
    ../../common/cli/fish
    ../../common/cli/fzf
    ../../common/cli/mpv
    ../../common/cli/nano
    ../../common/cli/starship
    ../../common/cli/tree
  ];
in
{
  home.stateVersion = "25.11";
  imports =
    appConfigs
    ++ commonConfigs
    ;
}
