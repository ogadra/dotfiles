{
  pkgs,
  lib,
  ...
}:
{
  home.packages = [ pkgs.alt-tab-macos ];

  targets.darwin.defaults."com.lwouis.alt-tab-macos" = {
    # サムネイルの揃え方: 0=左揃え, 1=中央揃え
    alignThumbnails = 1;

    # ウィンドウパネルのサイズ: 0=小, 1=中, 2=大, 3=最大
    appearanceSize = "1";

    # カラーテーマ: 0=システム, 1=ライト, 2=ダーク
    appearanceTheme = 2;

    # パネルの表示タイミング: 0=ホールドキー押下後すぐ, 1=遅延後
    appearanceVisibility = 1;

    # 表示するアプリ: 0=すべてのSpaceのアプリ, 1=現在のSpaceのアプリ
    appsToShow = 0;

    # 矢印キーでのナビゲーション有効化
    arrowKeysEnabled = "false";

    # クラッシュ時のポリシー: 0=何もしない, 1=自動再起動
    crashPolicy = 1;

    # カーソルをフォーカスに追従: 0=しない
    cursorFollowFocus = 0;
    cursorFollowFocusEnabled = 0;

    # アプリごとの表示例外リスト
    # ignore: 0=ショートカット有効, 1=常に無効, 2=フルスクリーン時のみ無効
    # hide:   0=常に表示, 1=常に非表示, 2=ウィンドウなしのとき非表示
    exceptions = builtins.toJSON [
      { bundleIdentifier = "com.apple.finder"; ignore = "0"; hide = "2"; }
      { bundleIdentifier = "com.apple.mail";   ignore = "0"; hide = "2"; }
    ];

    # ウィンドウなしアプリを隠す
    hideWindowlessApps = 1;

    # 設定ファイルのバージョン
    preferencesVersion = "10.11.0";

    # 表示するスクリーン: 0=すべてのスクリーン, 1=showOnScreenと同じスクリーンのみ
    screensToShow = 0;

    # 初回起動時に設定画面を表示済みとする
    settingsWindowShownOnFirstLaunch = "true";

    # ショートカット数
    shortcutCount = "1";

    # ショートカットスタイル: 0=⌘+Tab, 1=カスタム
    shortcutStyle = 0;

    # フルスクリーンウィンドウを表示: 0=常に表示, 1=現在のSpaceのみ, 2=非表示
    showFullscreenWindows = 0;

    # 隠しウィンドウを表示: 0=常に表示, 1=現在のSpaceのみ, 2=非表示
    showHiddenWindows = 2;

    # 最小化ウィンドウを表示: 0=常に表示, 1=元のSpaceに表示, 2=非表示
    showMinimizedWindows = 0;

    # パネルを表示するスクリーン: 0=アクティブなスクリーン, 1=マウスカーソルがあるスクリーン, 2=メニューバーがあるスクリーン
    showOnScreen = "0";

    # ウィンドウタイトルの表示: 0=非表示, 1=タイトルのみ, 2=アプリ名+タイトル
    showTitles = 2;

    # ウィンドウなしアプリの表示: 0=表示, 1=非表示, 2=末尾に表示
    showWindowlessApps = 1;

    # 2つ目以降のショートカット用のウィンドウなしアプリ表示設定 (shortcutCount=1のため未使用)
    showWindowlessApps10 = "0";

    # 表示するSpace: 0=すべてのSpace, 1=現在のSpace
    spacesToShow = 0;

    # テーマ: 0=macOSデフォルト, 1=macOS
    theme = 1;

    # トラックパッドの触覚フィードバック
    trackpadHapticFeedbackEnabled = "false";

    # アップデートポリシー: 0=自動確認, 1=確認しない
    updatePolicy = "0";

    # パネル表示の遅延 (ミリ秒)
    windowDisplayDelay = 0;

    # 最大ウィンドウ幅 (行の割合 %)
    windowMaxWidthInRow = 30;
  };

  # ショートカット設定はNSKeyedArchiverバイナリ形式のため targets.darwin.defaults では扱えない。
  # defaults import でplistから適用する。targets.darwin.defaults より後に実行されることを保証するため
  # writeBoundary の後に実行する (targets.darwin.defaults は linkGeneration 前に適用される)。
  home.activation.altTabShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/defaults import com.lwouis.alt-tab-macos ${./com.lwouis.alt-tab-macos.plist}
  '';
}
