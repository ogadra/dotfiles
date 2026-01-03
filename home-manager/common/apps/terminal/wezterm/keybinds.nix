{ ... }:
{
  xdg.configFile."wezterm/keybinds.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
      local act = wezterm.action


    config.disable_default_key_bindings = true
    config.send_composed_key_when_alt_is_pressed = false
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
    }
    end

    return module
  '';
}
