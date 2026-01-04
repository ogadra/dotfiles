{ ... }:
{
  xdg.configFile."wezterm/assets/plus-pattern.png".source = ./assets/plus-pattern.png;

  xdg.configFile."wezterm/background.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      local config_dir = wezterm.config_dir
      config.kde_window_background_blur = true

      config.background = {
        {
          source = { File = config_dir .. '/assets/plus-pattern.png' },
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
