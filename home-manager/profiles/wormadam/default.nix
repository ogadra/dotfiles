{ ... }:
let
  # GUI Applications (cross-platform)
  appConfigs = [
    ../../common/apps/1password
    ../../common/apps/alt-tab
    ../../common/apps/chrome
    ../../common/apps/discord
    ../../common/apps/editor/emacs
    ../../common/apps/karabiner
    ../../common/apps/macskk
    ../../common/apps/mos
    ../../common/apps/raycast
    ../../common/apps/shottr
    ../../common/apps/terminal
  ];

  # CLI tools (cross-platform)
  commonConfigs = [
    ../../common/cli/bat
    ../../common/cli/direnv
    ../../common/cli/git
    ../../common/cli/gh
    ../../common/cli/ghq
    ../../common/cli/gnumake
    ../../common/cli/gomi
    ../../common/cli/fish
    ../../common/cli/fzf
    ../../common/cli/nano
    ../../common/cli/starship
    ../../common/cli/tree
    ../../common/cli/zsh
  ];
in
{
  home.stateVersion = "25.11";
  imports = appConfigs ++ commonConfigs;
}
