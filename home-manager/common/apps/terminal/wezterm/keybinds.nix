{ pkgs, config, ... }:
let
  herdrBin = "${config.programs.herdr.package}/bin/herdr";
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  mod = if isLinux then "ALT" else "SUPER";
  altCompose = if isLinux then "" else ''
    config.send_composed_key_when_left_alt_is_pressed = false
    config.send_composed_key_when_right_alt_is_pressed = false
  '';
in
{
  xdg.configFile."wezterm/keybinds.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      local act = wezterm.action

      -- Send the herdr prefix (C-q = \x11) followed by a command key
      local function herdr(cmd)
        return act.SendString('\x11' .. cmd)
      end

      -- Tabs of the session this window runs, counted across every workspace; nil when the query fails
      local function herdr_tabs(session)
        local ok, stdout = wezterm.run_child_process { '${herdrBin}', '--session', session, 'tab', 'list' }
        if not ok then
          return nil
        end
        -- A stopped session answers with an error object instead of a result
        local decoded, payload = pcall(wezterm.json_parse, stdout)
        if not decoded or type(payload) ~= 'table' or not payload.result then
          return nil
        end
        return payload.result.tabs
      end

      -- Closing the last tab leaves herdr with nothing to show, so the window goes with it
      local close_tab = wezterm.action_callback(function(win, pane)
        local session = pane:get_user_vars().herdr_session
        local tabs = session and herdr_tabs(session)
        if not tabs or #tabs > 1 then
          win:perform_action(herdr('w'), pane)
          return
        end
        if tabs[1] then
          -- Close over the socket rather than the prefix key: the keystroke would race the window teardown
          wezterm.run_child_process { '${herdrBin}', '--session', session, 'tab', 'close', tabs[1].tab_id }
        end
        win:perform_action(act.CloseCurrentTab { confirm = false }, pane)
      end)

    config.disable_default_key_bindings = true
    ${altCompose}
    config.keys = {
      -- Window Control
      { key = 'n', mods = '${mod}', action = act.SpawnWindow },
      { key = 'q', mods = '${mod}', action = act.QuitApplication },
      { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
      { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
      { key = '=', mods = '${mod}', action = act.IncreaseFontSize },
      { key = '-', mods = '${mod}', action = act.DecreaseFontSize },

      -- Tab Control (delegated to herdr)
      { key = 't', mods = '${mod}', action = herdr('c') },
      { key = 'w', mods = '${mod}', action = close_tab },

      { key = 'Tab', mods = 'CTRL', action = herdr('n') },
      { key = 'Tab', mods = 'SHIFT|CTRL', action = herdr('p') },

      -- Workspace Control (delegated to herdr); a capital N is how herdr's prefix+shift+n arrives over a pty
      { key = 'T', mods = 'SHIFT|${mod}', action = herdr('N') },

      -- Copy & Paste
      { key = 'c', mods = '${mod}', action = act.CopyTo("Clipboard") },
      { key = 'v', mods = '${mod}', action = act.PasteFrom("Clipboard") },

      -- Line Edit
      { key = 'k', mods = 'CTRL', action = act.SendKey { key = 'k', mods = 'CTRL' } },

      -- Pane Split (delegated to herdr)
      { key = 'd', mods = '${mod}', action = herdr('%') },

      -- CopyMode (delegated to herdr)
      { key = "X", mods = "CTRL", action = herdr('[') },

      -- herdr prefix
      { key = 'q', mods = 'CTRL', action = act.SendString('\x11') },
    }

    -- herdr captures plain clicks, so the binding needs the mouse_reporting=true variant
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
