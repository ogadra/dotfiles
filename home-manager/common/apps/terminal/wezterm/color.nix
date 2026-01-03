{ ... }:
{
  xdg.configFile."wezterm/color.lua".text = ''
    local module = {}

    -- NERV HUD inspired colors (shared across modules)
    module.palette = {
      -- Base colors
      orange = '#f07820',
      black = '#1a1a1a',
      deep_black = '#0a0a0a',
      dim_orange = '#805030',
      white = '#ffffff',
      -- Status colors
      green = '#20d020',
      red = '#d02020',
      purple = '#a030e0',
      teal = '#30c0c0',
    }

    function module.apply_to_config(config, wezterm)
      local p = module.palette

      -- Font
      config.font = wezterm.font_with_fallback {
        'JetBrainsMono Nerd Font Mono',
        'Noto Sans Mono CJK JP',
      }
      config.font_size = 12.0

      -- NERV HUD inspired color scheme
      config.colors = {
        foreground = p.orange,
        background = '#000000',
        cursor_bg = p.orange,
        cursor_fg = p.deep_black,
        selection_bg = p.orange,
        selection_fg = p.deep_black,
        ansi = {
          p.black,    -- black
          p.red,      -- red (warning)
          p.green,    -- green (active)
          p.orange,   -- yellow -> NERV orange
          '#6868f0',  -- blue -> Eva purple-blue
          p.purple,   -- magenta -> Eva Unit 01 purple
          p.teal,     -- cyan -> teal accent
          '#b0b0b0',  -- white
        },
        brights = {
          '#404040',  -- bright black
          '#ff3030',  -- bright red (alert)
          '#30ff30',  -- bright green
          '#ff9020',  -- bright yellow -> bright orange
          '#8080ff',  -- bright blue
          '#c060e8',  -- bright magenta
          '#40f0f0',  -- bright cyan
          '#ffffff',  -- bright white
        },
      }
      config.window_background_opacity = 0.9
    end

    return module
  '';
}
