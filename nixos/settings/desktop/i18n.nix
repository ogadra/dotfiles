{
  pkgs,
  ...
}:
{
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS        = "ja_JP.UTF-8";
      LC_IDENTIFICATION = "ja_JP.UTF-8";
      LC_MEASUREMENT    = "ja_JP.UTF-8";
      LC_MONETARY       = "ja_JP.UTF-8";
      LC_NAME           = "ja_JP.UTF-8";
      LC_NUMERIC        = "ja_JP.UTF-8";
      LC_PAPER          = "ja_JP.UTF-8";
      LC_TELEPHONE      = "ja_JP.UTF-8";
      LC_TIME           = "ja_JP.UTF-8";
    };

    inputMethod = {
      enable = true;
      type   = "fcitx5";

      fcitx5 = {
        addons = with pkgs; ([
          fcitx5-skk
          fcitx5-gtk
        ] ++ (with skkDictionaries; [ l jinmei geo propernoun station assoc ]));
        waylandFrontend  = true;
        # TODO: home-manager側に寄せて`ignoreUserConfig`を消す
        ignoreUserConfig = true;

        settings = {
          globalOptions = {
            Hotkey = {
              EnumerateWithTriggerKeys = true;
            };
            "Hotkey/AltTriggerKeys" = { };
            "Hotkey/EnumerateForwardKeys"."0" = "Control+space";
            "Hotkey/EnumerateBackwardKeys" = { };
            "Hotkey/TriggerKeys"."0" = "Control+space";
          };
          inputMethod = {
            GroupOrder."0" = "Default";
            "Groups/0" = {
              Name             = "Default";
              "Default Layout" = "us";
              DefaultIM        = "skk";
            };
            "Groups/0/Items/0".Name = "skk";
          };
        };
      };
    };
  };
}
