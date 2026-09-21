{ lib, ... }:
let
  version = "1.104.19";
  dmgUrl = "https://releases.raycast.com/releases/${version}/download?build=universal";
  dmgSha256 = "ba453b5b9553ca9f09a52f55efe10c863add5ff9466e5bbf12c506ad1da2fc82";
in
{
  targets.darwin.defaults."com.raycast.macos" = {
    # Global hotkey; Command-49 is cmd+Space
    raycastGlobalHotkey = "Command-49";

    raycastWindowPresentationMode = 2;

    # Preferred window mode
    raycastPreferredWindowMode = "default";

    # Follow the system light and dark appearance
    raycastShouldFollowSystemAppearance = 1;

    # Hyper key icon in the menu bar
    useHyperKeyIcon = 0;

    # Force the input source to ABC when Raycast opens
    enforcedInputSourceIDOnOpen = "com.apple.keylayout.ABC";

    # Skin tone in the emoji picker
    emojiPicker_skinTone = "light";
  };

  home.activation.installRaycast = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/Raycast.app" ]; then
      _dmg=$(mktemp /tmp/raycast-XXXXXX.dmg)
      /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
      echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { rm -f "$_dmg"; exit 1; }
      _mnt=$(/usr/bin/mktemp -d /tmp/raycast-mnt-XXXXXX)
      /usr/bin/hdiutil attach "$_dmg" -mountpoint "$_mnt" -nobrowse -quiet
      /bin/cp -R "$_mnt/Raycast.app" /Applications/
      /usr/bin/xattr -dr com.apple.quarantine /Applications/Raycast.app
      /usr/bin/hdiutil detach "$_mnt" -quiet
      rm -f "$_dmg"
    fi
  '';
}
