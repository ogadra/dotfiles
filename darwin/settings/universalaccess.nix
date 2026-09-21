{ ... }:
{
  # com.apple.universalaccess only takes writes through defaults -currentHost; see https://github.com/LnL7/nix-darwin/issues/1049
  system.activationScripts.postActivation.text = ''
    defaults -currentHost write com.apple.universalaccess reduceMotion -bool true

    defaults -currentHost write com.apple.universalaccess reduceTransparency -bool true

    # Turns Tahoe's Liquid Glass effect all the way off; takes a reboot
    defaults write -g com.apple.SwiftUI.DisableSolarium -bool true
  '';
}
