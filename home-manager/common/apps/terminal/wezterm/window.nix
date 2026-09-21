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
      -- herdr paints edge to edge; a pixel just keeps the glyphs off the window frame
      config.window_padding = {
        left = '1px',
        right = '1px',
        top = '1px',
        bottom = '1px',
      }
      config.use_ime = true
      config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'
    end

    return module
  '';
}
