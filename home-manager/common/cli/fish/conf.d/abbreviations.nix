{ pkgs, ... }:
{
  programs.fish.shellAbbrs = {
    cl = "claude";
    copy = if pkgs.stdenv.hostPlatform.isLinux then "wl-copy" else "pbcopy";
    de = "devin";
  };
}
