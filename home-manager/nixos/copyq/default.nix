{ pkgs, ... }:
{
  home.packages = [ pkgs.copyq ];

  # Autostart with XCB mode for paste functionality on Wayland
  xdg.configFile."autostart/copyq.desktop".text = ''
    [Desktop Entry]
    Name=CopyQ
    Exec=env QT_QPA_PLATFORM=xcb copyq --start-server
    Type=Application
    X-KDE-autostart-phase=1
  '';

  # CopyQ configuration
  xdg.configFile."copyq/copyq.conf".text = ''
    [General]

    [Options]
    activate_closes=true
    activate_focuses=true
    activate_pastes=true
    clipboard_tab=&clipboard
    close_on_unfocus=true
  '';

  # Desktop entry for CopyQ menu (used by KDE global shortcut)
  xdg.dataFile."applications/copyq-menu.desktop".text = ''
    [Desktop Entry]
    Name=CopyQ Menu
    Comment=Show clipboard history
    Exec=copyq menu
    Type=Application
    Icon=copyq
    NoDisplay=true
  '';
}
