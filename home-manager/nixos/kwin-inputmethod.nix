{ pkgs, ... }:
let
  inputMethodDesktop = "/run/current-system/sw/share/applications/fcitx5-wayland-launcher.desktop";
  dbusArgs           = "a{saay} 1 Wayland 1 11 73 110 112 117 116 77 101 116 104 111 100";
  script             = pkgs.writeShellScript "kwin-set-inputmethod" ''
    set -eu
    kwriteconfig6 --file kwinrc --group Wayland --key InputMethod "${inputMethodDesktop}"
    busctl --user emit /kwinrc org.kde.kconfig.notify ConfigChanged "${dbusArgs}"
  '';
in
{
  systemd.user.services.kwin-inputmethod = {
    Unit = {
      Description = "Set KWin Wayland InputMethod to fcitx5";
      After       = [ "graphical-session.target" ];
      PartOf      = [ "graphical-session.target" ];
    };
    Service = {
      Type      = "oneshot";
      ExecStart = script;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
