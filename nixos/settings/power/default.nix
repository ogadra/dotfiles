{ ... }:
{
  services.logind = {
    settings.Login = {
      HandlePowerKey = "suspend";
      HandlePowerKeyLongPress = "poweroff";
    };
  };
}
