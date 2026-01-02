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
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];
        waylandFrontend  = true;
        # TODO: home-manager側に寄せて`ignoreUserConfig`を消す
        ignoreUserConfig = true;

        settings = {
          inputMethod = {
            GroupOrder."0" = "Default";
            "Groups/0" = {
              Name             = "Default";
              "Default Layout" = "us";
              DefaultIM        = "mozc";
            };
            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "mozc";
          };
        };
      };
    };
  };
}
