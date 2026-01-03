{ ... }:
{
  # Disable Klipper to avoid conflict with CopyQ
  xdg.configFile."klipperrc".text = ''
    [General]
    KeepClipboardContents=false
    MaxClipItems=0
    SyncClipboards=false
  '';
}
