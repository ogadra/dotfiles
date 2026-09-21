{ lib, ... }:
let
  # The nixpkgs build is ad-hoc signed, so its cdhash shifts on every rebuild and TCC grants like screen recording lapse with it; the official build is notarized and identified by TeamIdentifier, so the grants stick
  version = "11.4.3";
  zipUrl = "https://github.com/lwouis/alt-tab-macos/releases/download/v${version}/AltTab-${version}.zip";
  zipSha256 = "f6471d3cfc3ca70986ab55fe2dd334da5ad629d517eaf8eb3449fc0e7123eddd";
in
{
  targets.darwin.defaults."com.lwouis.alt-tab-macos" = {
    # Thumbnail alignment: 0=left, 1=center
    alignThumbnails = 1;

    # Panel size: 0=small, 1=medium, 2=large, 3=largest
    appearanceSize = "1";

    # Color theme: 0=system, 1=light, 2=dark
    appearanceTheme = 2;

    # Panel timing: 0=as soon as the hold key is pressed, 1=after a delay
    appearanceVisibility = 1;

    # Apps listed: 0=from every Space, 1=from the current Space
    appsToShow = 0;

    arrowKeysEnabled = "false";

    # On crash: 0=do nothing, 1=relaunch
    crashPolicy = 1;

    cursorFollowFocus = 0;
    cursorFollowFocusEnabled = 0;

    # Per-app exceptions; ignore: 0=shortcut on, 1=always off, 2=off only in full screen; hide: 0=always show, 1=always hide, 2=hide when windowless
    exceptions = builtins.toJSON [
      { bundleIdentifier = "com.apple.finder"; ignore = "0"; hide = "2"; }
      { bundleIdentifier = "com.apple.mail";   ignore = "0"; hide = "2"; }
    ];

    hideWindowlessApps = 1;

    preferencesVersion = "10.11.0";

    previewFocusedWindow = "true";

    # Screens listed: 0=all, 1=only the one showOnScreen picks
    screensToShow = 0;

    # Mark the first-launch settings window as already seen
    settingsWindowShownOnFirstLaunch = "true";

    shortcutCount = "1";

    # Shortcut style: 0=cmd+Tab, 1=custom
    shortcutStyle = 0;

    # Full-screen windows: 0=always show, 1=hide, 2=show last
    showFullscreenWindows = 0;

    # Hidden windows: 0=always show, 1=hide, 2=show last
    showHiddenWindows = 1;

    # Minimized windows: 0=always show, 1=hide, 2=show last
    showMinimizedWindows = 0;

    # Screen the panel opens on: 0=active, 1=the one under the cursor, 2=the one with the menu bar
    showOnScreen = "0";

    # Window titles: 0=hide, 1=title only, 2=app name and title
    showTitles = 2;

    # Windowless apps: 0=show, 1=hide, 2=show last
    showWindowlessApps = 1;

    # Windowless apps for the second shortcut onward, unused while shortcutCount is 1
    showWindowlessApps10 = "0";

    # Spaces listed: 0=all, 1=the current one
    spacesToShow = 0;

    # Theme: 0=macOS default, 1=macOS
    theme = 1;

    trackpadHapticFeedbackEnabled = "false";

    # Updates: 0=check automatically, 1=never check
    updatePolicy = "0";

    # Delay in milliseconds before the panel appears
    windowDisplayDelay = 0;

    # Widest a window may get, as a percentage of the row
    windowMaxWidthInRow = 30;
  };

  home.activation.installAltTab = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/AltTab.app" ]; then
      _zip=$(mktemp /tmp/alttab-XXXXXX.zip)
      /usr/bin/curl -L -o "$_zip" "${zipUrl}"
      echo "${zipSha256}  $_zip" | /usr/bin/shasum -a 256 -c - || { rm -f "$_zip"; exit 1; }
      _dir=$(/usr/bin/mktemp -d /tmp/alttab-dir-XXXXXX)
      /usr/bin/unzip -q "$_zip" -d "$_dir"
      /bin/cp -R "$_dir/AltTab.app" /Applications/
      /usr/bin/xattr -dr com.apple.quarantine /Applications/AltTab.app
      rm -rf "$_zip" "$_dir"
    fi
  '';

  # Shortcuts are NSKeyedArchiver blobs that targets.darwin.defaults cannot write, so import the plist after writeBoundary, which is where that option has already been applied
  home.activation.altTabShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/defaults import com.lwouis.alt-tab-macos ${./com.lwouis.alt-tab-macos.plist}
  '';
}
