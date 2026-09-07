{ ... }:
{
  xdg.configFile."wezterm/focus.lua".text = ''
    local module = {}

    local border_width = '4px'
    local unfocused_backdrop = '#3a3a3a'
    local unfocused_opacity = 0.6

    local function rgb(hex)
      return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
    end

    local function saturation_value(r, g, b)
      local hi, lo = math.max(r, g, b), math.min(r, g, b)
      return (hi - lo) / hi, hi / 255
    end

    local function backdrop_blend_hsb(hex)
      local a = unfocused_opacity
      local r, g, b = rgb(hex)
      local br, bg, bb = rgb(unfocused_backdrop)
      local s, v = saturation_value(r, g, b)
      local blended_s, blended_v = saturation_value(
        r * a + br * (1 - a),
        g * a + bg * (1 - a),
        b * a + bb * (1 - a)
      )
      return { saturation = blended_s / s, brightness = blended_v / v }
    end

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

      local unfocused_text_hsb = backdrop_blend_hsb(p.orange)

      wezterm.on('window-focus-changed', function(window)
        local overrides = window:get_config_overrides() or {}
        if window:is_focused() then
          overrides.window_frame = nil
          overrides.background = nil
          overrides.foreground_text_hsb = nil
          overrides.text_background_opacity = nil
        else
          overrides.window_frame = frame(unfocused_backdrop)
          overrides.background = {
            {
              source = { Color = unfocused_backdrop },
              width = '100%',
              height = '100%',
            },
          }
          overrides.foreground_text_hsb = unfocused_text_hsb
          overrides.text_background_opacity = unfocused_opacity
        end
        window:set_config_overrides(overrides)
      end)
    end

    return module
  '';
}
