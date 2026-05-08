{ ... }:
let
  appConfigs = [
    ../../common/apps/chrome
    ../../common/apps/discord
    ../../common/apps/editor
    ../../common/apps/obs
    ../../common/apps/spotify
    ../../common/apps/terminal
  ];

  commonConfigs = [
    ../../common/cli/claude-code
    ../../common/cli/codex
    ../../common/cli/direnv
    ../../common/cli/fish
    ../../common/cli/fzf
    ../../common/cli/gh
    ../../common/cli/ghq
    ../../common/cli/git
    ../../common/cli/gnumake
    ../../common/cli/jq
    ../../common/cli/mpv
    ../../common/cli/starship
    ../../common/cli/takt
    ../../common/cli/tree
    ../../common/cli/unzip
    ../../common/cli/zsh
  ];

  nixDesktopConfigs = [
    ../../nixos/kwin
    ../../nixos/mouse
    ../../nixos/klipper
    ../../nixos/wl-clipboard
    ../../nixos/wofi
    ../../nixos/cliphist
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
