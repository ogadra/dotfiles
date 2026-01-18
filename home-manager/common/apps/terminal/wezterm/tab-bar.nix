{ ... }:
{
  xdg.configFile."wezterm/tab-bar.lua".text = ''
    local module = {}
    local color = require 'color'
    local p = color.palette

    -- Cache for git root per path
    local git_root_cache = {}
    -- Cache for right status width
    local right_status_width = 0
    local left_status_width = 11  -- " TERMINAL " = 10 chars + separator

    -- Tab bar colors
    local tab_colors = {
      bg = p.orange,
      active_bg = p.black,
      active_fg = p.orange,
      inactive_bg = p.deep_black,
      inactive_fg = p.dim_orange,
      hover_bg = p.dim_orange,
      hover_fg = p.white,
    }

    -- Get git branch name
    local function get_git_branch(wezterm, cwd)
      if not cwd then
        return nil
      end
      local success, stdout, stderr = wezterm.run_child_process({
        'git', '-C', cwd, 'rev-parse', '--abbrev-ref', 'HEAD'
      })
      if success then
        return stdout:gsub('%s+$', "")
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

    -- Get git repository root
    local function get_git_root(wezterm, cwd)
      if not cwd then
        return nil
      end
      local success, stdout, stderr = wezterm.run_child_process({
        'git', '-C', cwd, 'rev-parse', '--show-toplevel'
      })
      if success then
        return stdout:gsub('%s+$', "")
      end
      return nil
    end

    -- Extract file path from URL or return as-is
    local function extract_path(url_or_path)
      if not url_or_path then
        return nil
      end
      -- Handle file:// URLs (e.g., file://hostname/path or file:///path)
      local path = url_or_path:match('^file://[^/]*(/.*)$')
      if path then
        return path
      end
      -- Already a path
      if url_or_path:sub(1, 1) == '/' then
        return url_or_path
      end
      return nil
    end

    -- Update git root cache (call from coroutine context like update-status)
    local function update_git_root_cache(wezterm, url_or_path)
      local path = extract_path(url_or_path)
      if not path then
        return
      end
      if git_root_cache[path] == nil then
        local git_root = get_git_root(wezterm, path)
        git_root_cache[path] = git_root or false  -- false means "not a git repo"
      end
    end

    -- Get path relative to git root, or shortened path if not in a git repo
    -- Uses cache, does not call external processes
    local function get_display_path(url_or_path)
      local path = extract_path(url_or_path)
      if not path then
        return ""
      end
      local git_root = git_root_cache[path]
      if git_root then
        local repo_name = git_root:match('[^/]+$') or git_root
        if path == git_root then
          return repo_name
        end
        local relative = path:sub(#git_root + 2)
        return repo_name .. '/' .. relative
      end
      return shorten_path(path)
    end

    -- Build git status text from cwd
    local function build_git_text(wezterm, cwd_path)
      local branch = get_git_branch(wezterm, cwd_path)
      if not branch then
        return nil
      end

      local parts = { ' ' .. branch }
      local ahead, behind = get_git_ahead_behind(wezterm, cwd_path)
      if ahead and ahead > 0 then table.insert(parts, '⇡' .. ahead) end
      if behind and behind > 0 then table.insert(parts, '⇣' .. behind) end

      local changes = get_git_changes(wezterm, cwd_path)
      if changes then
        if changes.staged > 0 then table.insert(parts, '+' .. changes.staged) end
        if changes.modified > 0 then table.insert(parts, '~' .. changes.modified) end
        if changes.untracked > 0 then table.insert(parts, '?' .. changes.untracked) end
      end
      return table.concat(parts, ' ')
    end

    -- Add a status segment with NERV style (black text on orange separator, then content)
    local function add_status_segment(parts, text, separator)
      table.insert(parts, { Foreground = { Color = p.black } })
      table.insert(parts, { Background = { Color = p.orange } })
      table.insert(parts, { Text = separator })
      table.insert(parts, { Foreground = { Color = p.orange } })
      table.insert(parts, { Background = { Color = p.black } })
      table.insert(parts, { Text = ' ' .. text .. ' ' .. separator })
    end

    function module.apply_to_config(config, wezterm)
      local SOLID_LEFT = wezterm.nerdfonts.ple_lower_right_triangle
      local SOLID_RIGHT = wezterm.nerdfonts.ple_upper_left_triangle

      -- Window title
      wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
        return 'TERMINAL'
      end)

      -- Left status
      wezterm.on('update-status', function(window, pane)
        window:set_left_status(wezterm.format({
          { Foreground = { Color = p.black } },
          { Background = { Color = p.orange } },
          { Text = ' TERMINAL ' },
          { Foreground = { Color = p.orange } },
          { Background = { Color = p.black } },
        }))
      end)

      -- Right status: HUD style
      wezterm.on('update-right-status', function(window, pane)
        local cwd = pane:get_current_working_dir()
        local cwd_path = cwd and (cwd.file_path or tostring(cwd)) or nil

        -- Update git root cache for all tabs
        for _, tab in ipairs(window:mux_window():tabs()) do
          local tab_pane = tab:active_pane()
          local tab_cwd = tab_pane:get_current_working_dir()
          if tab_cwd then
            update_git_root_cache(wezterm, tab_cwd.file_path or tostring(tab_cwd))
          end
        end

        local git_text = build_git_text(wezterm, cwd_path)
        local hostname = wezterm.hostname():gsub('%..*', "")
        local time = wezterm.strftime('%H:%M:%S')

        local status_parts = {}
        local total_width = 1  -- trailing cap

        if git_text then
          add_status_segment(status_parts, git_text, SOLID_LEFT)
          total_width = total_width + #git_text + 4  -- text + separators + padding
        end
        add_status_segment(status_parts, hostname, SOLID_LEFT)
        total_width = total_width + #hostname + 4
        add_status_segment(status_parts, time, SOLID_LEFT)
        total_width = total_width + #time + 4

        right_status_width = total_width

        -- Trailing cap
        table.insert(status_parts, { Foreground = { Color = p.black } })
        table.insert(status_parts, { Background = { Color = p.orange } })
        table.insert(status_parts, { Text = ' ' })

        window:set_right_status(wezterm.format(status_parts))
      end)

      -- Tab title: NERV HUD style
      wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
        local pane = tab.active_pane
        local cwd = pane.current_working_dir
        local dir_text = ""

        if cwd then
          local path = cwd.file_path or tostring(cwd)
          dir_text = get_display_path(path)
        end

        local is_active = tab.is_active
        local bg = is_active and tab_colors.active_bg or tab_colors.inactive_bg
        local fg = is_active and tab_colors.active_fg or tab_colors.inactive_fg

        local title = dir_text
        -- Calculate available width: terminal width - left status - right status - tab decorations
        local term_width = pane.width or 80
        local num_tabs = #tabs
        local tab_decorations = 4  -- separators and padding per tab
        local available_per_tab = math.floor((term_width - left_status_width - right_status_width) / num_tabs) - tab_decorations
        local available_width = math.min(max_width - tab_decorations, available_per_tab)
        if available_width > 0 and #title > available_width then
          title = '...' .. title:sub(-(available_width - 3))
        end

        return {
          { Background = { Color = tab_colors.bg } },
          { Foreground = { Color = bg } },
          { Text = ' ' .. SOLID_LEFT },
          { Background = { Color = bg } },
          { Foreground = { Color = fg } },
          { Text = ' ' .. title .. ' ' },
          { Background = { Color = tab_colors.bg } },
          { Foreground = { Color = bg } },
          { Text = SOLID_RIGHT },
        }
      end)

      -- Tab bar settings
      config.use_fancy_tab_bar = false
      config.tab_bar_at_bottom = false
      config.hide_tab_bar_if_only_one_tab = false
      config.tab_max_width = 50

      config.colors = config.colors or {}
      config.colors.tab_bar = {
        background = tab_colors.bg,
        active_tab = {
          bg_color = tab_colors.active_bg,
          fg_color = tab_colors.active_fg,
        },
        inactive_tab = {
          bg_color = tab_colors.inactive_bg,
          fg_color = tab_colors.inactive_fg,
        },
        inactive_tab_hover = {
          bg_color = tab_colors.hover_bg,
          fg_color = tab_colors.hover_fg,
        },
      }
    end

    return module
  '';
}
