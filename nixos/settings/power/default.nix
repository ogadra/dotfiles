{ ... }:
{
  services.logind = {
    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
  };
}
