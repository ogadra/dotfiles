{ ... }:
{
  xdg.configFile."kwinrc".text = ''
    [Desktops]
    Id_1=f85849e5-8864-41c1-b683-fe7b23d68ae7
    Number=1
    Rows=1

    [ElectricBorders]
    Bottom=None
    BottomLeft=None
    BottomRight=None
    Left=None
    Right=None
    Top=None
    TopLeft=None
    TopRight=None

    [Effect-overview]
    BorderActivate=9

    [Effect-windowview]
    BorderActivateAll=9
    BorderActivateClass=9

    [Plugins]
    screenedgeEnabled=false

    [Wayland]
    InputMethod=/run/current-system/sw/share/applications/fcitx5-wayland-launcher.desktop

    [Windows]
    EdgeBarrier=0
    ElectricBorderMaximize=false
    ElectricBorderTiling=false

    [Xwayland]
    Scale=1.5
  '';
}
