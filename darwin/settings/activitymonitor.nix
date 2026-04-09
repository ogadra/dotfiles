{ ... }:
{
  system.defaults.ActivityMonitor = {
    # 表示するプロセス
    # 100=全て, 101=階層, 102=自分, 103=システム,
    # 104=他ユーザー, 105=アクティブ, 106=非アクティブ, 107=ウィンドウ付き
    ShowCategory = 102;

    # Dockアイコンの種類
    # 0=アプリアイコン, 2=ネットワーク, 3=ディスク, 5=CPU, 6=CPU履歴
    IconType = 0;

    # ソート列
    SortColumn = "Command";

    # ソート方向: 0=降順, 1=昇順
    SortDirection = 1;

    # 起動時にメインウィンドウを開く
    OpenMainWindow = true;
  };
}
