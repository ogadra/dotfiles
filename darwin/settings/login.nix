{ ... }:
{
  system.defaults.loginwindow = {
    # ゲストログイン
    GuestEnabled = false;

    # ユーザーリストではなく名前/パスワード入力欄を表示
    SHOWFULLNAME = true;

    # ログイン画面に表示するテキスト
    LoginwindowText = null;

    # 自動ログインユーザー
    autoLoginUser = null;

    # ログイン画面のシャットダウンボタン
    ShutDownDisabled = false;

    # ログイン画面のスリープボタン
    SleepDisabled = false;

    # ログイン画面の再起動ボタン
    RestartDisabled = false;

    # ログイン中のAppleメニューからシャットダウンを無効化
    ShutDownDisabledWhileLoggedIn = false;

    # ログイン中のAppleメニューから電源OFFを無効化
    PowerOffDisabledWhileLoggedIn = false;

    # ログイン中のAppleメニューから再起動を無効化
    RestartDisabledWhileLoggedIn = false;

    # ログイン画面での >console によるCUIアクセスを無効化
    DisableConsoleAccess = false;
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.loginwindow" = {
      # ログアウト時にウィンドウ状態を保存しない
      TALLogoutSavesState = false;
    };
  };
}
