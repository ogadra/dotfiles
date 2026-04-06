{ ... }:
{
  system.defaults.WindowManager = {
    # Stage Manager
    GloballyEnabled = false;

    # クリックでデスクトップを表示
    EnableStandardClickToShowDesktop = false;

    # デスクトップアイコンを隠す
    StandardHideDesktopIcons = true;

    # デスクトップを隠す
    HideDesktop = true;

    # ウィジェットを隠す
    StandardHideWidgets = true;
  };

  # アプリ切替時にそのアプリがあるSpaceに自動移動しない
  system.defaults.NSGlobalDomain.AppleSpacesSwitchOnActivate = false;
}
