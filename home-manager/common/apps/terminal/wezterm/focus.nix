{ pkgs, ... }:
let
  # Blur is unavailable on Linux (see background.nix), so a see-through
  # unfocused window would just look broken there; keep it opaque.
  unfocusedOpacity = if pkgs.stdenv.hostPlatform.isLinux then "1.0" else "0.5";
in
{
  xdg.configFile."wezterm/focus.lua".text = ''
    local module = {}

    local focused_border_width = '6px'
    local unfocused_border_width = '4px'
    local unfocused_border = '#3a3a3a'
    local unfocused_opacity = ${unfocusedOpacity}

    local unfocused_colors = {
      foreground = '#caa153',
      background = '#000000',
      cursor_bg = '#caa153',
      cursor_fg = '#0a0a0a',
      selection_bg = '#caa153',
      selection_fg = '#0a0a0a',
      ansi = {
        '#1a1a1a',
        '#b85443',
        '#43b153',
        '#caa153',
        '#6655ca',
        '#b243c1',
        '#4397a6',
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
        [16] = '#caa153',
        [17] = '#1a1a1a',
        [18] = '#0a0a0a',
        [19] = '#8c6b2e',
      },
      -- set_config_overrides replaces colors wholesale, so the tab bar has to
      -- be restated here or it falls back to the wezterm defaults.
      tab_bar = {
        background = '#caa153',
        active_tab = {
          bg_color = '#1a1a1a',
          fg_color = '#caa153',
        },
        inactive_tab = {
          bg_color = '#0a0a0a',
          fg_color = '#8c6b2e',
        },
        inactive_tab_hover = {
          bg_color = '#8c6b2e',
          fg_color = '#d0d0d0',
        },
      },
    }

    function module.apply_to_config(config, wezterm)
      local color = require 'color'
      local p = color.palette

      local function frame(border_color, border_width)
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

      config.window_frame = frame(p.orange, focused_border_width)

      wezterm.on('window-focus-changed', function(window)
        local overrides = window:get_config_overrides() or {}
        if window:is_focused() then
          overrides.window_frame = nil
          overrides.colors = nil
          overrides.window_background_opacity = nil
        else
          overrides.window_frame = frame(unfocused_border, unfocused_border_width)
          overrides.colors = unfocused_colors
          overrides.window_background_opacity = unfocused_opacity
        end
        window:set_config_overrides(overrides)
      end)
    end

    return module
  '';
}
