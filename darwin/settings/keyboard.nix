{ ... }:
{
  system.defaults.NSGlobalDomain = {
    # キーリピート開始までの遅延 (小さいほど速い, 最速=10)
    InitialKeyRepeat = 15;

    # キーリピート速度 (小さいほど速い, 最速=1)
    KeyRepeat = 2;

    # true: 長押しでアクセント文字パネル / false: キーリピート
    ApplePressAndHoldEnabled = false;

    # 文頭の自動大文字化
    NSAutomaticCapitalizationEnabled = false;

    # -- を em dash に自動置換
    NSAutomaticDashSubstitutionEnabled = false;

    # スペース2回でピリオド自動挿入
    NSAutomaticPeriodSubstitutionEnabled = false;

    # straight quotes を curly quotes に自動置換
    NSAutomaticQuoteSubstitutionEnabled = false;

    # 自動スペル修正
    NSAutomaticSpellingCorrectionEnabled = false;
  };
}
