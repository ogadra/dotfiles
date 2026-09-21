{ ... }:
{
  system.defaults.WindowManager = {
    # Stage Manager
    GloballyEnabled = false;

    # Click the wallpaper to reveal the desktop
    EnableStandardClickToShowDesktop = false;

    # Hide desktop icons
    StandardHideDesktopIcons = true;

    # Hide the desktop
    HideDesktop = true;

    # Hide widgets
    StandardHideWidgets = true;
  };

  # Jump to the Space that already holds the app being switched to
  system.defaults.NSGlobalDomain.AppleSpacesSwitchOnActivate = false;
}
