{ ... }:
{
  services.espanso = {
    enable = true;

    # KDE Plasma 6 hosts run Wayland only, so skip building the X11 variant; ignored on macOS
    x11Support = false;

    # Disable the search bar popup so its shortcut stays free for the app launcher; accepts a key combo like "ALT+SPACE" or "off"
    configs.default.search_shortcut = "off";

    matches.base.matches = [
      {
        trigger = ";c";
        replace = "continue";
      }
    ];
  };
}
