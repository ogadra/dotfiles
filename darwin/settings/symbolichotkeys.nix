{ config, lib, ... }:
let
  user = lib.escapeShellArg config.system.primaryUser;
in
{
  # CustomUserPreferences would replace the whole AppleSymbolicHotKeys dict and drop the other shortcuts, so -dict-add rewrites only this entry
  system.activationScripts.postActivation.text = ''
    # 61 is "Select next source in Input menu"; parameters are (ASCII code, key code, modifier mask), so 32, 49, 262144 is Ctrl+Space, which herdr's copy mode needs for its character selection
    launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>'
    # The hotkey server reads the dict only at login unless activateSettings reloads it
    launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
