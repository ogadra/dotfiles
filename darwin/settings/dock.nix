{ ... }:
{
  system.defaults.dock = {
    # Hide the Dock automatically
    autohide = true;

    # Seconds before the hidden Dock slides back in; an hour keeps it away for good
    autohide-delay = 3600.0;

    # Bounce animation while an app launches
    launchanim = false;

    # Window minimize effect: "genie" | "scale"
    mineffect = "scale";

    # Reorder Spaces by most recent use
    mru-spaces = false;

    # Dock icon size
    tilesize = 1;

    # Indicator dot under running apps
    show-process-indicators = false;

    # Show recently used apps in the Dock
    show-recents = false;
  };
}
