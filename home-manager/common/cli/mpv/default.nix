{ lib, pkgs, ... }:
{
  programs.mpv.enable = true;

  # Agent hooks play sounds through mpv, and the default regular policy makes it the frontmost app, so the terminal loses focus when it quits; macOS-only option
  programs.mpv.config = lib.mkIf (!pkgs.stdenv.hostPlatform.isLinux) {
    macos-app-activation-policy = "prohibited";
  };
}
