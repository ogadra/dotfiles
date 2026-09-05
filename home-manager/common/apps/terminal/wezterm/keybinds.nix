{ pkgs, ... }:
let
  mod = if pkgs.stdenv.isDarwin then "SUPER" else "ALT";
  altCompose = if pkgs.stdenv.isDarwin then ''
    config.send_composed_key_when_left_alt_is_pressed = false
    config.send_composed_key_when_right_alt_is_pressed = false
  '' else "";
in
{
  xdg.configFile."wezterm/keybinds.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      local act = wezterm.action

      -- Send the tmux prefix (C-q = \x11) followed by a command key
      local function tmux(cmd)
        return act.SendString('\x11' .. cmd)
      end

    config.disable_default_key_bindings = true
    ${altCompose}
    config.keys = {
      -- Window Control
      { key = 'n', mods = '${mod}', action = act.SpawnWindow },
      { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
      { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
      { key = '=', mods = '${mod}', action = act.IncreaseFontSize },
      { key = '-', mods = '${mod}', action = act.DecreaseFontSize },

      -- Tab Control (delegated to tmux)
      { key = 't', mods = '${mod}', action = tmux('c') },
      { key = 'w', mods = '${mod}', action = tmux('w') },

      { key = 'Tab', mods = 'CTRL', action = tmux('n') },
      { key = 'Tab', mods = 'SHIFT|CTRL', action = tmux('p') },

      -- Copy & Paste
      { key = 'c', mods = '${mod}', action = act.CopyTo("Clipboard") },
      { key = 'v', mods = '${mod}', action = act.PasteFrom("Clipboard") },

      -- Line Edit
      { key = 'k', mods = 'CTRL', action = act.SendKey { key = 'k', mods = 'CTRL' } },

      -- Pane Split (delegated to tmux)
      { key = 'd', mods = '${mod}', action = tmux('%') },

      -- CopyMode (delegated to tmux)
      { key = "X", mods = "CTRL", action = tmux('[') },

      -- tmux prefix
      { key = 'q', mods = 'CTRL', action = act.SendString('\x11') },
    }

    -- Open the link under the cursor with Ctrl+click. tmux's mouse mode makes
    -- wezterm forward plain clicks to tmux, so the mouse_reporting=true variant
    -- is required for the binding to fire inside tmux panes.
    config.mouse_bindings = {
      {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = act.OpenLinkAtMouseCursor,
      },
      {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        mouse_reporting = true,
        action = act.OpenLinkAtMouseCursor,
      },
    }

    end

    return module
  '';
}
