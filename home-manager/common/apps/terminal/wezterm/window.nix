{ ... }:
{
  xdg.configFile."wezterm/window.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      config.window_close_confirmation = 'NeverPrompt'
      config.automatically_reload_config = true
    end

    return module
  '';
}
