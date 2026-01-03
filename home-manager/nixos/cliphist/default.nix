{ pkgs, ... }:
let
  # Alt+V paste script (xremap converts Alt+V to Ctrl+V)
  # Key codes: 56=Alt, 47=V
  cliphist-paste = pkgs.writeScriptBin "cliphist-paste" ''
    #!${pkgs.bash}/bin/bash
    selected=$(cliphist list | wofi -S dmenu)
    if [ -n "$selected" ]; then
      echo "$selected" | cliphist decode | wl-copy
      ydotool key 56:1 47:1 47:0 56:0
    fi
  '';
in
{
  home.packages = [
    pkgs.cliphist
    pkgs.ydotool
    cliphist-paste
  ];

  # Autostart cliphist to watch clipboard
  xdg.configFile."autostart/cliphist.desktop".text = ''
    [Desktop Entry]
    Name=Cliphist
    Exec=wl-paste --watch cliphist store
    Type=Application
  '';

  # Desktop entry for cliphist menu (used by KDE global shortcut)
  xdg.dataFile."applications/cliphist-menu.desktop".text = ''
    [Desktop Entry]
    Name=Cliphist Menu
    Comment=Show clipboard history
    Exec=cliphist-paste
    Type=Application
    Icon=edit-paste
    NoDisplay=true
  '';
}
