{ config, lib, ... }:
let
  version = "1.1.1";
  zipUrl = "https://github.com/Hammerspoon/hammerspoon/releases/download/${version}/Hammerspoon-${version}.zip";
  zipSha256 = "11bb1c90faf5427f37c7bd4fe7eab9774ae43e1d5cb020c5b3088dac32849efa";
in
{
  targets.darwin.defaults."org.hammerspoon.Hammerspoon" = {
    MJConfigFile = "${config.xdg.configHome}/hammerspoon/init.lua";
  };

  # Same keys and actions as the Raycast Window Management hotkeys on stakataka
  xdg.configFile."hammerspoon/init.lua".text = ''
    hs.autoLaunch(true)
    hs.window.animationDuration = 0

    local function withFocusedWindow(action)
      return function()
        local win = hs.window.focusedWindow()
        if win then
          action(win)
        end
      end
    end

    local function moveToUnit(unit)
      return withFocusedWindow(function(win)
        win:moveToUnit(unit)
      end)
    end

    hs.hotkey.bind({ "alt" }, "left", moveToUnit(hs.layout.left50))
    hs.hotkey.bind({ "alt" }, "right", moveToUnit(hs.layout.right50))
    hs.hotkey.bind({ "alt" }, "up", moveToUnit(hs.layout.maximized))

    hs.hotkey.bind({ "alt", "shift" }, "left", withFocusedWindow(function(win)
      win:moveToScreen(win:screen():next(), false, true)
    end))
    hs.hotkey.bind({ "alt", "shift" }, "right", withFocusedWindow(function(win)
      win:moveToScreen(win:screen():previous(), false, true)
    end))
  '';

  home.activation.installHammerspoon = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/Hammerspoon.app" ]; then
      _zip=$(mktemp /tmp/hammerspoon-XXXXXX.zip)
      /usr/bin/curl -L -o "$_zip" "${zipUrl}"
      echo "${zipSha256}  $_zip" | /usr/bin/shasum -a 256 -c - || { rm -f "$_zip"; exit 1; }
      _dir=$(/usr/bin/mktemp -d /tmp/hammerspoon-dir-XXXXXX)
      /usr/bin/unzip -q "$_zip" -d "$_dir"
      /bin/cp -R "$_dir/Hammerspoon.app" /Applications/
      /usr/bin/xattr -dr com.apple.quarantine /Applications/Hammerspoon.app
      rm -rf "$_zip" "$_dir"
    fi
  '';
}
