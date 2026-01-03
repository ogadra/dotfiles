{ ... }:
let
  kwinShortcuts = import ./kwin.nix { };
  plasmashellShortcuts = import ./plasmashell.nix { };
  mediaShortcuts = import ./media.nix { };
  systemShortcuts = import ./system.nix { };
  copyqShortcuts = import ./copyq.nix { };
in
{
  xdg.configFile."kglobalshortcutsrc".text =
    systemShortcuts.system
    + mediaShortcuts.media
    + kwinShortcuts.kwin
    + plasmashellShortcuts.plasmashell
    + copyqShortcuts.copyq;
}
