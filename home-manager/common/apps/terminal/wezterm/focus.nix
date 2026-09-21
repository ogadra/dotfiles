{ ... }:
let
  nerv = import ../../../theme/nerv.nix;
in
{
  xdg.configFile."wezterm/focus.lua".text = ''
    local module = {}

    -- One width for both states: changing it reflows every cell the moment focus moves
    local border_width = '6px'
    local unfocused_border = '#3a3a3a'
    local unfocused_opacity = 0.85

    -- herdr's chrome is truecolor, so only an HSB pass hazes it like the palette swap does
    local unfocused_hsb = { saturation = 0.7, brightness = 0.8 }

    local unfocused_colors = {
      foreground = '${nerv.unfocused.orange}',
      background = '#000000',
      cursor_bg = '${nerv.unfocused.orange}',
      cursor_fg = '${nerv.unfocused.deepBlack}',
      selection_bg = '${nerv.unfocused.orange}',
      selection_fg = '${nerv.unfocused.deepBlack}',
      ansi = {
        '${nerv.unfocused.black}',
        '${nerv.unfocused.red}',
        '${nerv.unfocused.green}',
        '${nerv.unfocused.orange}',
        '${nerv.unfocused.blue}',
        '${nerv.unfocused.purple}',
        '${nerv.unfocused.teal}',
        '#a6a6a6',
      },
      brights = {
        '#3a3a3a',
        '#dd6a55',
        '#55d469',
        '#e6b65c',
        '#826eef',
        '#d65ce6',
        '#55b9ca',
        '#cacaca',
      },
      indexed = {
        [16] = '${nerv.unfocused.orange}',
        [17] = '${nerv.unfocused.black}',
        [18] = '${nerv.unfocused.deepBlack}',
        [19] = '${nerv.unfocused.dimOrange}',
        [20] = '#0c3a13',
        [21] = '#4a1910',
        [22] = '#1a6a26',
        [23] = '#8a2b1a',
        [24] = '#bb784c',
        [25] = '#d59266',
        [26] = '#de762c',
        [27] = '#d06620',
        [28] = '#d1de21',
        [29] = '#ab5969',
      },
      tab_bar = {
        background = '${nerv.unfocused.orange}',
        active_tab = {
          bg_color = '${nerv.unfocused.black}',
          fg_color = '${nerv.unfocused.orange}',
        },
        inactive_tab = {
          bg_color = '${nerv.unfocused.deepBlack}',
          fg_color = '${nerv.unfocused.dimOrange}',
        },
        inactive_tab_hover = {
          bg_color = '${nerv.unfocused.dimOrange}',
          fg_color = '${nerv.unfocused.white}',
        },
      },
    }

    function module.apply_to_config(config, wezterm)
      local color = require 'color'
      local p = color.palette

      local function frame(border_color)
        return {
          inactive_titlebar_bg = "none",
          active_titlebar_bg = "none",
          font = wezterm.font('JetBrainsMono Nerd Font Mono'),
          font_size = 12.0,
          border_left_width = border_width,
          border_right_width = border_width,
          border_top_height = border_width,
          border_bottom_height = border_width,
          border_left_color = border_color,
          border_right_color = border_color,
          border_top_color = border_color,
          border_bottom_color = border_color,
        }
      end

      config.window_frame = frame(p.orange)

      wezterm.on('window-focus-changed', function(window)
        local overrides = window:get_config_overrides() or {}
        if window:is_focused() then
          overrides.window_frame = nil
          overrides.colors = nil
          overrides.window_background_opacity = nil
          overrides.foreground_text_hsb = nil
        else
          overrides.window_frame = frame(unfocused_border)
          overrides.colors = unfocused_colors
          overrides.window_background_opacity = unfocused_opacity
          overrides.foreground_text_hsb = unfocused_hsb
        end
        window:set_config_overrides(overrides)
      end)
    end

    return module
  '';
}
