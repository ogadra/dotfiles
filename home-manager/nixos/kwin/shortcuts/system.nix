{ ... }:
{
  # Session management, power, and accessibility shortcuts
  system = ''
    [ActivityManager]
    _k_friendly_name=Activity Manager

    [KDE Keyboard Layout Switcher]
    Switch to Last-Used Keyboard Layout=Meta+Alt+L,Meta+Alt+L,Switch to Last-Used Keyboard Layout
    Switch to Next Keyboard Layout=Meta+Alt+K,Meta+Alt+K,Switch to Next Keyboard Layout
    _k_friendly_name=Keyboard Layout Switcher

    [kaccess]
    Toggle Screen Reader On and Off=Meta+Alt+S,Meta+Alt+S,Toggle Screen Reader On and Off
    _k_friendly_name=Accessibility

    [ksmserver]
    Halt Without Confirmation=none,,Shut Down Without Confirmation
    Lock Session=Screensaver,Meta+L\tScreensaver,Lock Session
    Log Out=Ctrl+Alt+Del,Ctrl+Alt+Del,Show Logout Screen
    Log Out Without Confirmation=none,,Log Out Without Confirmation
    LogOut=none,,Log Out
    Reboot=none,,Reboot
    Reboot Without Confirmation=none,,Reboot Without Confirmation
    Shut Down=none,,Shut Down
    _k_friendly_name=Session Management

    [org_kde_powerdevil]
    Decrease Keyboard Brightness=Keyboard Brightness Down,Keyboard Brightness Down,Decrease Keyboard Brightness
    Decrease Screen Brightness=Monitor Brightness Down,Monitor Brightness Down,Decrease Screen Brightness
    Decrease Screen Brightness Small=Shift+Monitor Brightness Down,Shift+Monitor Brightness Down,Decrease Screen Brightness by 1%
    Hibernate=Hibernate,Hibernate,Hibernate
    Increase Keyboard Brightness=Keyboard Brightness Up,Keyboard Brightness Up,Increase Keyboard Brightness
    Increase Screen Brightness=Monitor Brightness Up,Monitor Brightness Up,Increase Screen Brightness
    Increase Screen Brightness Small=Shift+Monitor Brightness Up,Shift+Monitor Brightness Up,Increase Screen Brightness by 1%
    PowerDown=Power Down,Power Down,Power Down
    PowerOff=Power Off,Power Off,Power Off
    Sleep=Sleep,Sleep,Suspend
    Toggle Keyboard Backlight=Keyboard Light On/Off,Keyboard Light On/Off,Toggle Keyboard Backlight
    Turn Off Screen=none,none,Turn Off Screen
    _k_friendly_name=Power Management
    powerProfile=Battery\tMeta+B,Battery\tMeta+B,Switch Power Profile
  '';
}
