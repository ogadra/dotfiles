{ ... }:
{
  xdg.configFile."wezterm/tab-bar.lua".text = ''
    local module = {}

    -- Colors matching starship.toml
    local colors = {
      time_bg = '#00ff00',      -- bright-green
      time_fg = '#000000',      -- black
      hostname_bg = '#00ffff',  -- bright-cyan
      hostname_fg = '#000000',  -- black
      dir_bg = '#5555ff',       -- bright-blue
      dir_fg = '#000000',       -- black
      git_bg = '#ff55ff',       -- bright-purple
      git_fg = '#000000',       -- black
    }

    -- Get git branch for a directory
    local function get_git_branch(wezterm, cwd)
      if not cwd then
        return nil
      end
      local success, stdout, stderr = wezterm.run_child_process({
        'git', '-C', cwd, 'rev-parse', '--abbrev-ref', 'HEAD'
      })
      if success then
        return stdout:gsub('%s+', "")
      end
      return nil
    end

    -- Shorten home directory to ~
    local function shorten_path(path)
      local home = os.getenv('HOME')
      if home and path:sub(1, #home) == home then
        return '~' .. path:sub(#home + 1)
      end
      return path
    end

    function module.apply_to_config(config, wezterm)
      -- Right status: hostname + time
      wezterm.on('update-right-status', function(window, pane)
        local hostname = wezterm.hostname():gsub('%..*', "")
        local time = wezterm.strftime('%H:%M:%S')
        window:set_right_status(wezterm.format({
          { Foreground = { Color = colors.hostname_fg } },
          { Background = { Color = colors.hostname_bg } },
          { Text = ' ' .. hostname .. ' ' },
          { Foreground = { Color = colors.time_fg } },
          { Background = { Color = colors.time_bg } },
          { Text = '  ' .. time .. ' ' },
        }))
      end)

      -- Tab title: directory + git branch
      wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
        local pane = tab.active_pane
        local cwd = pane.current_working_dir
        local dir_text = ""
        local git_text = ""

        if cwd then
          local path = cwd.file_path or tostring(cwd)
          dir_text = shorten_path(path)
          local branch = get_git_branch(wezterm, path)
          if branch then
            git_text = '  ' .. branch
          end
        end

        local max_len = max_width - 4
        if #dir_text + #git_text > max_len then
          local available = max_len - #git_text - 3
          if available > 0 then
            dir_text = '...' .. dir_text:sub(-available)
          end
        end

        return {
          { Foreground = { Color = colors.dir_fg } },
          { Background = { Color = colors.dir_bg } },
          { Text = ' ' .. dir_text .. ' ' },
          { Foreground = { Color = colors.git_fg } },
          { Background = { Color = colors.git_bg } },
          { Text = git_text ~= "" and git_text .. ' ' or "" },
        }
      end)

      -- Tab bar settings
      config.use_fancy_tab_bar = false
      config.tab_bar_at_bottom = false
      config.hide_tab_bar_if_only_one_tab = false
      config.tab_max_width = 50

      config.colors = config.colors or {}
      config.colors.tab_bar = {
        background = '#1e1e1e',
        active_tab = {
          bg_color = colors.dir_bg,
          fg_color = colors.dir_fg,
        },
        inactive_tab = {
          bg_color = '#3e3e3e',
          fg_color = '#808080',
        },
        inactive_tab_hover = {
          bg_color = '#4e4e4e',
          fg_color = '#c0c0c0',
        },
      }
    end

    return module
  '';
}
