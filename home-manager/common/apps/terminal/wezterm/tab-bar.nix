{ ... }:
{
  xdg.configFile."wezterm/tab-bar.lua".text = ''
    local module = {}

    -- NERV HUD inspired colors
    local colors = {
      time_bg = '#20d020',       -- green (system active)
      time_fg = '#1a1a1a',       -- deep black
      hostname_bg = '#f07820',   -- NERV orange
      hostname_fg = '#1a1a1a',   -- deep black
      dir_bg = '#a030e0',        -- Eva Unit 01 purple
      dir_fg = '#ffffff',        -- white
      git_bg = '#30c0c0',        -- teal accent
      git_fg = '#1a1a1a',        -- deep black
      git_status_bg = '#d02020', -- warning red
      git_status_fg = '#ffffff', -- white
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

    -- Get git ahead/behind counts
    local function get_git_ahead_behind(wezterm, cwd)
      if not cwd then
        return nil, nil
      end
      local success, stdout, stderr = wezterm.run_child_process({
        'git', '-C', cwd, 'rev-list', '--left-right', '--count', 'HEAD...@{upstream}'
      })
      if success then
        local ahead, behind = stdout:match('(%d+)%s+(%d+)')
        return tonumber(ahead), tonumber(behind)
      end
      return nil, nil
    end

    -- Get git file change counts
    local function get_git_changes(wezterm, cwd)
      if not cwd then
        return nil
      end
      local success, stdout, stderr = wezterm.run_child_process({
        'git', '-C', cwd, 'status', '--porcelain'
      })
      if not success then
        return nil
      end

      local staged, modified, untracked = 0, 0, 0
      for line in stdout:gmatch('[^\n]+') do
        local index = line:sub(1, 1)
        local worktree = line:sub(2, 2)
        if index == '?' then
          untracked = untracked + 1
        elseif index ~= ' ' and index ~= '?' then
          staged = staged + 1
        end
        if worktree ~= ' ' and worktree ~= '?' then
          modified = modified + 1
        end
      end
      return { staged = staged, modified = modified, untracked = untracked }
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
      -- Right status: git status + hostname + time
      wezterm.on('update-right-status', function(window, pane)
        local cwd = pane:get_current_working_dir()
        local cwd_path = cwd and (cwd.file_path or tostring(cwd)) or nil

        -- Build git status text
        local git_parts = {}
        local ahead, behind = get_git_ahead_behind(wezterm, cwd_path)
        if ahead and ahead > 0 then
          table.insert(git_parts, '⇡' .. ahead)
        end
        if behind and behind > 0 then
          table.insert(git_parts, '⇣' .. behind)
        end

        local changes = get_git_changes(wezterm, cwd_path)
        if changes then
          if changes.staged > 0 then
            table.insert(git_parts, '+' .. changes.staged)
          end
          if changes.modified > 0 then
            table.insert(git_parts, '~' .. changes.modified)
          end
          if changes.untracked > 0 then
            table.insert(git_parts, '?' .. changes.untracked)
          end
        end

        local git_text = table.concat(git_parts, ' ')
        local hostname = wezterm.hostname():gsub('%..*', "")
        local time = wezterm.strftime('%H:%M:%S')

        local status_parts = {}

        -- Git status section (only if there's something to show)
        if git_text ~= "" then
          table.insert(status_parts, { Foreground = { Color = colors.git_status_fg } })
          table.insert(status_parts, { Background = { Color = colors.git_status_bg } })
          table.insert(status_parts, { Text = '  ' .. git_text .. ' ' })
        end

        -- Hostname section
        table.insert(status_parts, { Foreground = { Color = colors.hostname_fg } })
        table.insert(status_parts, { Background = { Color = colors.hostname_bg } })
        table.insert(status_parts, { Text = ' ' .. hostname .. ' ' })

        -- Time section
        table.insert(status_parts, { Foreground = { Color = colors.time_fg } })
        table.insert(status_parts, { Background = { Color = colors.time_bg } })
        table.insert(status_parts, { Text = '  ' .. time .. ' ' })

        window:set_right_status(wezterm.format(status_parts))
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
        background = '#0a0a0a',          -- deep black
        active_tab = {
          bg_color = colors.dir_bg,
          fg_color = colors.dir_fg,
        },
        inactive_tab = {
          bg_color = '#1a1a1a',          -- dark gray
          fg_color = '#ff6b00',          -- NERV orange
        },
        inactive_tab_hover = {
          bg_color = '#2a2a2a',
          fg_color = '#ff8c00',          -- brighter orange
        },
      }
    end

    return module
  '';
}
