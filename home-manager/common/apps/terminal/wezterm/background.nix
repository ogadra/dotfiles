{ pkgs, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
  platformConfig =
    if isLinux then
      "    config.kde_window_background_blur = true\n"
    else if isDarwin then
      "    config.macos_window_background_blur = 12\n    config.window_background_opacity = 0.9\n"
    else "";
in
{
  xdg.configFile."wezterm/assets/plus-pattern.png".source = ./assets/plus-pattern.png;

  xdg.configFile."wezterm/background.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      local config_home = os.getenv('HOME') .. '/.config/wezterm'
${platformConfig}
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
