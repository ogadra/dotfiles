{ ... }:
{
  xdg.configFile."wezterm/color.lua".text = ''
    local module = {}

    -- NERV HUD inspired colors (shared across modules)
    module.palette = {
      -- Base colors
      orange = '#ff8a25',
      black = '#1a1a1a',
      deep_black = '#0a0a0a',
      dim_orange = '#935c37',
      white = '#ffffff',
      -- Status colors
      green = '#25ef25',
      red = '#ef2525',
      purple = '#b837ff',
      teal = '#37dddd',
    }

    function module.apply_to_config(config, wezterm)
      local p = module.palette

      -- Font
      config.font = wezterm.font_with_fallback {
        'JetBrainsMono Nerd Font Mono',
        'Noto Sans Mono CJK JP',
      }
      config.font_size = 16.0
      config.line_height = 1.2

      -- Cursor (blinking HUD style)
      config.cursor_blink_rate = 500
      config.default_cursor_style = 'BlinkingBlock'
      config.cursor_thickness = 2

      -- Selection
      config.selection_word_boundary = ' \t\n{}[]()"\x27'

      -- Inactive pane dim (focus effect)
      config.inactive_pane_hsb = {
        saturation = 0.7,
        brightness = 0.6,
      }

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
          '#7878ff',  -- blue -> Eva purple-blue
          p.purple,   -- magenta -> Eva Unit 01 purple
          p.teal,     -- cyan -> teal accent
          '#cacaca',  -- white
        },
        brights = {
          '#404040',  -- bright black
          '#ff3737',  -- bright red (alert)
          '#37ff37',  -- bright green
          '#ffa625',  -- bright yellow -> bright orange
          '#9393ff',  -- bright blue
          '#dd6eff',  -- bright magenta
          '#4affff',  -- bright cyan
          '#ffffff',  -- bright white
        },
        indexed = {
          [16] = p.orange,
          [17] = p.black,
          [18] = p.deep_black,
          [19] = p.dim_orange,
          [20] = '#0c3a0c',
          [21] = '#4a1010',
          [22] = '#1a6a1a',
          [23] = '#8a1a1a',
          [24] = '#d77757',
          [25] = '#f59575',
          [26] = '#ff6933',
          [27] = '#ef5825',
          [28] = '#ffed26',
          [29] = '#c46686',
        },
      }
    end

    return module
  '';
}
