{ ... }:
{
  xdg.configFile."wezterm/keybinds.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      local act = wezterm.action


    config.disable_default_key_bindings = true
    config.send_composed_key_when_left_alt_is_pressed = false
    config.send_composed_key_when_right_alt_is_pressed = false
    config.keys = {
      -- Window Control
      { key = 'n', mods = 'ALT', action = act.SpawnWindow },
      { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
      { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
      { key = '=', mods = 'ALT', action = act.IncreaseFontSize },
      { key = '-', mods = 'ALT', action = act.DecreaseFontSize },

      -- Tab Control
      { key = 't', mods = 'ALT', action = act.SpawnTab("CurrentPaneDomain") },
      { key = 'w', mods = 'ALT', action = act.CloseCurrentTab({ confirm = false }) },

      { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
      { key = 'Tab', mods = 'SHIFT|CTRL', action = act.ActivateTabRelative(-1) },

      -- Copy & Paste
      { key = 'c', mods = 'ALT', action = act.CopyTo("Clipboard") },
      { key = 'Insert', mods = 'CTRL', action = act.CopyTo("Clipboard") },
      { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom("Clipboard") },

      -- Line Edit
      { key = 'k', mods = 'CTRL', action = act.SendKey { key = 'k', mods = 'CTRL' } },

      -- Pane Split
      { key = 'd', mods = 'ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

      -- CopyMode
      {
        key = "X",
        mods = "CTRL",
        action = act.Multiple({
          act.ActivateCopyMode,
          act.CopyMode("ClearPattern"),
          act.CopyMode("ClearSelectionMode"),
          act.CopyMode("MoveToViewportMiddle"),
        }),
      },
    }

    config.key_tables = {
      copy_mode = {
        -- Exit
        { key = "Escape", mods = "NONE", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
        { key = "g", mods = "CTRL", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
        { key = "q", mods = "NONE", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },

        -- Cursor movement
        { key = "f", mods = "CTRL", action = act.CopyMode("MoveRight") },
        { key = "b", mods = "CTRL", action = act.CopyMode("MoveLeft") },
        { key = "p", mods = "CTRL", action = act.CopyMode("MoveUp") },
        { key = "n", mods = "CTRL", action = act.CopyMode("MoveDown") },
        { key = "a", mods = "CTRL", action = act.CopyMode("MoveToStartOfLineContent") },
        { key = "e", mods = "CTRL", action = act.CopyMode("MoveToEndOfLineContent") },

        -- Word movement
        { key = "f", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
        { key = "b", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },

        -- Page/scroll movement
        { key = "v", mods = "CTRL", action = act.CopyMode("PageDown") },
        { key = "v", mods = "ALT", action = act.CopyMode("PageUp") },
        { key = "<", mods = "ALT", action = act.CopyMode("MoveToScrollbackTop") },
        { key = ">", mods = "ALT", action = act.CopyMode("MoveToScrollbackBottom") },

        -- Selection (C-Space to set mark)
        { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
        { key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
        { key = "V", mods = "CTRL|SHIFT", action = act.CopyMode({ SetSelectionMode = "Block" }) },

        -- Copy (M-w) and cancel selection (C-g)
        { key = "w", mods = "ALT", action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }) },

        -- Search
        { key = "s", mods = "CTRL", action = act.Search("CurrentSelectionOrEmptyString") },
        { key = "r", mods = "CTRL", action = act.Search("CurrentSelectionOrEmptyString") },
      }
    }
    end

    return module
  '';
}
