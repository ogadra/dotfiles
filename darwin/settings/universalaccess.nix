{ ... }:
{
  # com.apple.universalaccess は defaults -currentHost でしか書き込めない
  # ref: https://github.com/LnL7/nix-darwin/issues/1049
  system.activationScripts.postActivation.text = ''
    # 画面切替等のアニメーションを軽減
    defaults -currentHost write com.apple.universalaccess reduceMotion -bool true

    # メニューバーやサイドバー等の透過効果を無効化
    defaults -currentHost write com.apple.universalaccess reduceTransparency -bool true

    # Tahoe の Liquid Glass (ガラス効果) を完全無効化（再起動後に反映）
    defaults write -g com.apple.SwiftUI.DisableSolarium -bool true
  '';
}
