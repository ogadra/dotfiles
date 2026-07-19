{ pkgs, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
  # KWin 6.7 dropped the org_kde_kwin_blur protocol and wezterm does not yet
  # speak its replacement (ext-background-effect, wezterm PR #7615), so blur
  # is unavailable on Linux; keep the window fully opaque there.
  platformConfig =
    if isLinux then
      "    config.window_background_opacity = 1.0\n"
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
