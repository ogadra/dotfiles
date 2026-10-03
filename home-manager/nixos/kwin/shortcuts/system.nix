{ ... }:
{
  # Session management, power, and accessibility shortcuts
  programs.plasma.shortcuts = {
    "KDE Keyboard Layout Switcher" = {
      "Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
      "Switch to Next Keyboard Layout" = "Meta+Alt+K";
    };
    kaccess."Toggle Screen Reader On and Off" = "Meta+Alt+S";
    ksmserver = {
      "Halt Without Confirmation" = [ ];
      "Lock Session" = "Ctrl+F11";
      "Log Out" = "Ctrl+Alt+Del";
      "Log Out Without Confirmation" = [ ];
      "LogOut" = [ ];
      "Reboot" = [ ];
      "Reboot Without Confirmation" = [ ];
      "Shut Down" = [ ];
    };
    org_kde_powerdevil = {
      "Decrease Keyboard Brightness" = "Keyboard Brightness Down";
      "Decrease Screen Brightness" = "Monitor Brightness Down";
      "Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
      "Hibernate" = "Hibernate";
      "Increase Keyboard Brightness" = "Keyboard Brightness Up";
      "Increase Screen Brightness" = "Monitor Brightness Up";
      "Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
      "PowerDown" = "Power Down";
      "PowerOff" = "Power Off";
      "Sleep" = "Sleep";
      "Toggle Keyboard Backlight" = "Keyboard Light On/Off";
      "Turn Off Screen" = [ ];
      "powerProfile" = [
        "Battery"
        "Meta+B"
      ];
    };
  };
}
