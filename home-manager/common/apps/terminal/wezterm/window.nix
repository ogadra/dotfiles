{ ... }:
{
  xdg.configFile."wezterm/window.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      config.window_close_confirmation = 'NeverPrompt'
      config.window_decorations = "RESIZE"
      config.automatically_reload_config = true
      config.window_frame = {
        inactive_titlebar_bg = "none",
        active_titlebar_bg = "none",
        font = wezterm.font('JetBrainsMono Nerd Font Mono'),
        font_size = 12.0,
      }
      config.show_new_tab_button_in_tab_bar = false
      config.show_close_tab_button_in_tabs = false
    end

    return module
  '';
}
