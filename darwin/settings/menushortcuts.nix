{ ... }:
{
  # The whole dict is replaced, so every app shortcut set in System Settings is listed here; ^ is Control, $ is Shift
  system.defaults.CustomUserPreferences.NSGlobalDomain.NSUserKeyEquivalents = {
    # Control+F11 matches KWin's "Lock Session"; Sleep cannot stand in for it since stakataka disables sleep with pmset
    "画面をロック" = "^" + builtins.fromJSON ''"\uf70e"'';
    "システム終了..." = "^$" + builtins.fromJSON ''"\u0004"'';
    "ページを再読み込み" = builtins.fromJSON ''"\u0008"'';
  };
}
