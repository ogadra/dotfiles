{ ... }:
{
  system.defaults.loginwindow = {
    # Guest login
    GuestEnabled = false;

    # Prompt for a name and password instead of listing users
    SHOWFULLNAME = true;

    # Message shown on the login screen
    LoginwindowText = null;

    # User logged in automatically
    autoLoginUser = null;

    # Shut down button on the login screen
    ShutDownDisabled = false;

    # Sleep button on the login screen
    SleepDisabled = false;

    # Restart button on the login screen
    RestartDisabled = false;

    # Shut down in the Apple menu while logged in
    ShutDownDisabledWhileLoggedIn = false;

    # Power off in the Apple menu while logged in
    PowerOffDisabledWhileLoggedIn = false;

    # Restart in the Apple menu while logged in
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
