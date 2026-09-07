{ ... }:
{
  xdg.configFile."wezterm/window.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      config.window_close_confirmation = 'NeverPrompt'
      config.window_decorations = "RESIZE"
      config.automatically_reload_config = true
      config.enable_tab_bar = false
      config.show_new_tab_button_in_tab_bar = false
      config.show_close_tab_button_in_tabs = false
      config.use_ime = true
      config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'
    end

    return module
  '';
}
