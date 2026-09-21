{ ... }:
{
  system.defaults.dock = {
    autohide = true;

    # An hour of delay keeps the hidden Dock from ever sliding back in
    autohide-delay = 3600.0;

    # Bounce animation while an app launches
    launchanim = false;

    # "genie" | "scale"
    mineffect = "scale";

    # Reorder Spaces by most recent use
    mru-spaces = false;

    # Icon size
    tilesize = 1;

    show-process-indicators = false;
    show-recents = false;
  };
}
