{ pkgs, ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  blurConfig =
    if isLinux then
      "config.wayland_window_background_blur = true"
    else
      "config.macos_window_background_blur = 12";
in
{
  xdg.configFile."wezterm/assets/plus-pattern.png".source = ./assets/plus-pattern.png;

  xdg.configFile."wezterm/background.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      local config_home = os.getenv('HOME') .. '/.config/wezterm'

      config.window_background_opacity = 0.9
      ${blurConfig}

      config.background = {
        {
          source = { File = config_home .. '/assets/plus-pattern.png' },
          repeat_x = 'Repeat',
          repeat_y = 'Repeat',
          width = 398,
          height = 398,
        },
      }
    end

    return module
  '';
}
