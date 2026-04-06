{ ... }:
{
  # ファイル拡張子を常に表示
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;

  system.defaults.finder = {
    # 隠しファイルを表示
    AppleShowAllFiles = true;

    # デフォルトの表示形式: Nlsv=リスト, icnv=アイコン, clmv=カラム, Flwv=ギャラリー
    FXPreferredViewStyle = "Nlsv";
  };
}
