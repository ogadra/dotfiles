{
  config,
  lib,
  pkgs,
  ...
}:
let
  paths =
    config.home.sessionPath
    ++ lib.optional pkgs.stdenv.hostPlatform.isLinux "/run/wrappers/bin"
    ++ [
      "$HOME/.nix-profile/bin"
      "/etc/profiles/per-user/${config.home.username}/bin"
      "/run/current-system/sw/bin"
      "/nix/var/nix/profiles/default/bin"
    ]
    ++ lib.optionals (!pkgs.stdenv.hostPlatform.isLinux) [
      "/usr/local/bin"
      "/usr/bin"
      "/bin"
      "/usr/sbin"
      "/sbin"
    ];
in
{
  imports = [
    ./conf.d/abbreviations.nix
    ./conf.d/aliases.nix
    ./conf.d/functions.nix
    ./theme.nix
  ];

  programs.fish = {
    enable = true;
    shellInit = ''
      set -g fish_user_paths
      set -gx PATH ${lib.concatStringsSep " " paths}
    '';
    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };
}
