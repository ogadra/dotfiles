{ ... }:
{
  # App shortcuts kglobalaccel reads from .desktop defaults; Meta+letter stays unbound so wezterm can hand Super, the macOS Option key's spot, to herdr
  programs.plasma.shortcuts = {
    "services/org.kde.dolphin.desktop"."_launch" = [ ];
    "services/systemsettings.desktop"."_launch" = "Tools";
    "services/org.kde.kscreen.desktop"."ShowOSD" = "Display";
    "services/org.kde.spectacle.desktop"."RecordRegion" = "Meta+Shift+R";
  };
}
