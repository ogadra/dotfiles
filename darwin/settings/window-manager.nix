{ ... }:
{
  system.defaults.WindowManager = {
    # Stage Manager
    GloballyEnabled = false;

    EnableStandardClickToShowDesktop = false;
    StandardHideDesktopIcons = true;
    HideDesktop = true;
    StandardHideWidgets = true;
  };

  # Jump to the Space that already holds the app being switched to
  system.defaults.NSGlobalDomain.AppleSpacesSwitchOnActivate = false;
}
