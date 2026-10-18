{ ... }:
{
  services.espanso = {
    enable = true;

    # KDE Plasma 6 hosts run Wayland only, so skip building the X11 variant; ignored on macOS
    x11Support = false;

    matches.base.matches = [
      {
        trigger = ";c";
        replace = "continue";
      }
    ];
  };
}
