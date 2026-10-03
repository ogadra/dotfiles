{ ... }:
let
  appConfigs = [
    ../../common/apps/brave
    ../../common/apps/chrome
    ../../common/apps/discord
    ../../common/apps/editor
    ../../common/apps/obs
    ../../common/apps/spotify
    ../../common/apps/terminal
  ];

  commonConfigs = [
    ../../common/cli/bat
    ../../common/cli/ccusage
    ../../common/cli/claude-code
    ../../common/cli/devin
    ../../common/cli/direnv
    ../../common/cli/fish
    ../../common/cli/fzf
    ../../common/cli/gh
    ../../common/cli/ghq
    ../../common/cli/git
    ../../common/cli/gitleaks
    ../../common/cli/gnumake
    ../../common/cli/gomi
    ../../common/cli/herdr
    ../../common/cli/hunk
    ../../common/cli/jq
    ../../common/cli/mpv
    ../../common/cli/rtk
    ../../common/cli/starship
    ../../common/cli/takt
    ../../common/cli/tree
    ../../common/cli/unzip
    ../../common/cli/zsh
  ];

  # devices/input.nix replaces nixos/mouse; xdg.configFile kcminputrc conflicts with plasma-manager
  nixDesktopConfigs = [
    ../../nixos/kwin
    ../../nixos/klipper
    ../../nixos/screenlocker
    ../../nixos/wl-clipboard
    ../../nixos/wofi
    ../../nixos/cliphist
    ../../nixos/xremap
  ];

  deviceConfigs = [
    ./devices/input.nix
    ./devices/xremap.nix
  ];
in
{
  home.stateVersion = "25.11";
  imports = appConfigs ++ commonConfigs ++ nixDesktopConfigs ++ deviceConfigs;
}
