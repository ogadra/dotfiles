{ config, lib, ... }:
let
  user = lib.escapeShellArg config.system.primaryUser;

  # A disabled entry needs no key; omitted ids fall back to macOS's enabled defaults
  disabled = {
    enabled = false;
  };
in
{
  # The whole dict is replaced, so every shortcut to keep disabled is listed here
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
    # Zoom on/off, Option+Command+8
    "15" = disabled;
    "16" = disabled;
    # Zoom in, Option+Command+=
    "17" = disabled;
    "18" = disabled;
    # Zoom out, Option+Command+-
    "19" = disabled;
    "20" = disabled;
    # Invert colors, Control+Option+Command+8
    "21" = disabled;
    "22" = disabled;
    # Image smoothing on/off, Option+Command+\
    "23" = disabled;
    "24" = disabled;
    # Increase contrast, Control+Option+Command+.
    "25" = disabled;
    # Decrease contrast, Control+Option+Command+,
    "26" = disabled;
    # Show Desktop, F11
    "36" = disabled;
    # Dock hiding on/off, Option+Command+D
    "52" = disabled;
    # Ctrl+Space selects the character selection in herdr's copy mode instead of the next input source
    "61" = disabled;
    # Spotlight search, Command+Space
    "64" = disabled;
    # Finder search window, Option+Command+Space
    "65" = disabled;
    # F8
    "75" = disabled;
    # Shift+F8
    "76" = disabled;
    # Move left a space, Control+Left
    "79" = disabled;
    # Move right a space, Control+Right
    "81" = disabled;
    # Switch to Desktop 1, Control+1
    "118" = disabled;
    # Switch to Desktop 2, Control+2
    "119" = disabled;
    # Switch to Desktop 3, Control+3
    "120" = disabled;
    # Switch to Desktop 4, Control+4
    "121" = disabled;
    "160" = disabled;
    "164" = disabled;
    "222" = disabled;
  };

  # The hotkey server reads the dict only at login unless activateSettings reloads it
  system.activationScripts.postActivation.text = ''
    launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
