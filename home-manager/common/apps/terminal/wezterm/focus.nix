{ ... }:
{
  xdg.configFile."wezterm/focus.lua".text = ''
    local module = {}

    local focused_border_width = '6px'
    local unfocused_border_width = '4px'
    local unfocused_border = '#3a3a3a'
    local unfocused_dim = 0.8
    local unfocused_layer_hsb = {
      saturation = 1.0,
      brightness = unfocused_dim ^ 2.4,
    }

    local function dim(hex)
      if type(hex) ~= 'string' or not hex:match('^#%x%x%x%x%x%x$') then
        return hex
      end
      local channels = {}
      for i = 0, 2 do
        channels[i + 1] = math.floor(tonumber(hex:sub(2 + i * 2, 3 + i * 2), 16) * unfocused_dim + 0.5)
      end
      return string.format('#%02x%02x%02x', channels[1], channels[2], channels[3])
    end

    local function dim_table(value)
      if type(value) == 'table' then
        local result = {}
        for k, v in pairs(value) do
          result[k] = dim_table(v)
        end
        return result
      end
      return dim(value)
    end

    local function dimmed_layers(layers)
      local result = {}
      for i, layer in ipairs(layers) do
        local copy = {}
        for k, v in pairs(layer) do
          copy[k] = v
        end
        copy.hsb = unfocused_layer_hsb
        result[i] = copy
      end
      return result
    end

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
          overrides.background = nil
          overrides.colors = nil
        else
          overrides.window_frame = frame(unfocused_border, unfocused_border_width)
          overrides.background = dimmed_layers(config.background)
          overrides.colors = dim_table(config.colors)
        end
        window:set_config_overrides(overrides)
      end)
    end

    return module
  '';
}
