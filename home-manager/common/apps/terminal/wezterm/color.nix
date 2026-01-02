{ ... }:
{
  xdg.configFile."wezterm/color.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      -- NERV HUD inspired color scheme
      config.colors = {
        foreground = '#f07820',     -- NERV orange
        background = '#000000',     -- Deep black
        cursor_bg = '#f07820',
        cursor_fg = '#0a0a0a',
        selection_bg = '#f07820',
        selection_fg = '#0a0a0a',
        ansi = {
          '#1a1a1a',  -- black
          '#d02020',  -- red (warning)
          '#20d020',  -- green (active)
          '#f07820',  -- yellow -> NERV orange
          '#6868f0',  -- blue -> Eva purple-blue
          '#a030e0',  -- magenta -> Eva Unit 01 purple
          '#30c0c0',  -- cyan -> teal accent
          '#b0b0b0',  -- white
        },
        brights = {
          '#404040',  -- bright black
          '#ff3030',  -- bright red (alert)
          '#30ff30',  -- bright green
          '#ff9020',  -- bright yellow -> bright orange
          '#c060e8',  -- bright magenta
          '#8080ff',  -- bright blue
          '#40f0f0',  -- bright cyan
          '#ffffff',  -- bright white
        },
      }
      config.window_background_opacity = 0.9
    end

    return module
  '';
}
