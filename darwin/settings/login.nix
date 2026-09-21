{ ... }:
{
  system.defaults.loginwindow = {
    GuestEnabled = false;

    # Prompt for a name and password instead of listing users
    SHOWFULLNAME = true;

    LoginwindowText = null;
    autoLoginUser = null;
    ShutDownDisabled = false;
    SleepDisabled = false;
    RestartDisabled = false;
    ShutDownDisabledWhileLoggedIn = false;
    PowerOffDisabledWhileLoggedIn = false;
    RestartDisabledWhileLoggedIn = false;

    # Console access through >console at the login screen
    DisableConsoleAccess = false;
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.loginwindow" = {
      # Save window state on logout
      TALLogoutSavesState = false;
    };
  };
}
