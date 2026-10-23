{
  pkgs,
  config,
  profile,
  ...
}:
let
  nerv = import ../../theme/nerv.nix;

  herdrBin = "${config.programs.herdr.package}/bin/herdr";

  # Herdr strips escape sequences from command entries, so emit plain text; storage reads the home volume because the macOS root is the sealed system snapshot
  loadSegment = pkgs.writeShellScript "herdr-load-segment" (
    if pkgs.stdenv.hostPlatform.isLinux then
      ''
        # /proc/stat counts since boot, so CPU is the busy share of a one-second delta
        read -r _ u1 n1 s1 i1 w1 q1 r1 _ </proc/stat
        sleep 1
        read -r _ u2 n2 s2 i2 w2 q2 r2 _ </proc/stat
        busy=$(((u2 + n2 + s2 + q2 + r2) - (u1 + n1 + s1 + q1 + r1)))
        idle=$(((i2 + w2) - (i1 + w1)))
        cpu=$((busy * 100 / (busy + idle)))
        mem=$(${pkgs.gawk}/bin/awk '/^MemTotal/ { t = $2 } /^MemAvailable/ { a = $2 } END { printf "%d", (t - a) * 100 / t }' /proc/meminfo)
        disk=$(df -P "$HOME" | ${pkgs.gawk}/bin/awk 'NR == 2 { sub(/%/, "", $5); print $5 }')
        printf 'CPU %s%%  MEM %s%%  DISK %s%%\n' "$cpu" "$mem" "$disk"
      ''
    else
      ''
        # ps reports decayed per-process averages, so summing them avoids top's multi-second sampling
        ncpu=$(/usr/sbin/sysctl -n hw.ncpu)
        cpu=$(/bin/ps -A -o %cpu= | /usr/bin/awk -v n="$ncpu" '{ s += $1 } END { printf "%d", s / n + 0.5 }')
        # memory_pressure's free share matches what Activity Monitor's pressure gauge reads
        mem=$(/usr/bin/memory_pressure | /usr/bin/awk '/free percentage/ { sub(/%/, "", $NF); print 100 - $NF }')
        disk=$(/bin/df -P "$HOME" | /usr/bin/awk 'NR == 2 { sub(/%/, "", $5); print $5 }')
        printf 'CPU %s%%  MEM %s%%  DISK %s%%\n' "$cpu" "$mem" "$disk"
      ''
  );

  # Publish the session name as a wezterm user var so its keybinds can drive this window's session; OSC 1337 takes a base64 value
  sessionExec = pkgs.writeShellScript "herdr-session-exec" ''
    printf '\033]1337;SetUserVar=herdr_session=%s\007' "$(printf %s "$1" | ${pkgs.coreutils}/bin/base64)"
    exec ${herdrBin} --session "$1"
  '';

in
{
  programs.herdr = {
    enable = true;
    # Patches the nixpkgs build instead of fetching our own release, so nixpkgs bumps carry the patch without a release workflow
    package = pkgs.herdr.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./patches/sidebar-tabs.patch ];
    });
    settings = {
      onboarding = false;

      terminal = {
        # New panes, tabs, and workspaces inherit the source pane's directory
        new_cwd = "follow";
      };

      keys = {
        prefix = "ctrl+q";

        # close_tab takes prefix+w, so the picker shifts one slot
        close_tab = [
          "prefix+w"
          "prefix+shift+x"
        ];
        workspace_picker = "prefix+shift+w";
        rename_tab = "f2";
        rename_workspace = "shift+f2";
        # tmux's session keys, which wezterm's Ctrl+Alt+(Shift+)Tab sends
        next_workspace = "prefix+)";
        previous_workspace = "prefix+(";

        # prefix+% is what wezterm's split key sends
        split_vertical = [
          "prefix+%"
          "prefix+v"
        ];
        split_horizontal = [
          ''prefix+"''
          "prefix+minus"
        ];
        detach = [
          "prefix+d"
          "prefix+q"
        ];
      };

      ui = {
        copy_on_select = true;
        mouse_scroll_lines = 2;
        # wezterm's new-tab key expects a tab to appear without a name prompt
        prompt_new_tab_name = false;
        # Lists tabs vertically in the sidebar; needs patches/sidebar-tabs.patch, upstream accepts only top and bottom
        tab_bar_position = "sidebar";

        # Needs patches/sidebar-tabs.patch; agent rows take the color of their space
        sidebar.spaces.colors = nerv.spaceTints;
        # Two rows like the patched tab list: the tab's name, then the pane's repo-relative path that the patch reports as $path
        sidebar.agents.rows = [
          [
            "state_icon"
            "tab"
          ]
          [ "$path" ]
        ];

        tab_bar_right = [
          # Separators land only between segments, so literals at both ends close the strip
          {
            type = "text";
            text = " ";
          }
          {
            type = "command";
            command = "${loadSegment}";
            # Linux samples /proc/stat for a second, so a 2-second timeout still leaves headroom
            interval_seconds = 5;
            timeout_seconds = 2;
          }
          {
            type = "text";
            text = profile;
          }
          {
            type = "datetime";
            format = "%m.%d %a %H:%M:%S";
          }
          {
            type = "text";
            text = " ";
          }
        ];
        # A slanted line: herdr draws the separator in one color, so a filled glyph reads as a wedge
        tab_bar_right_separator = "  ";
      };

      theme = {
        # Fall back to the wezterm palette for tokens that are not overridden
        name = "terminal";
        custom = {
          # Focused pane border and focused tab background; wezterm's ANSI yellow is the NERV orange and follows its palette swap
          accent = "yellow";
          # Unfocused pane border, and sidebar rows herdr does not have focus on
          overlay0 = nerv.unfocused.orange;
          panel_bg = nerv.focused.deepBlack;
          sidebar_bg = nerv.focused.deepBlack;
          active_row_bg = nerv.focused.black;
          selection_bg = nerv.focused.dimOrange;
          surface0 = nerv.focused.black;
          surface1 = nerv.focused.dimOrange;
          surface_dim = nerv.focused.deepBlack;
          # Paints the tab bar's right-hand status text, and inactive tab labels with it
          overlay1 = nerv.focused.orange;
          text = nerv.focused.orange;
          subtext0 = nerv.focused.dimOrange;
          mauve = nerv.focused.purple;
          green = nerv.focused.green;
          # NERV has no distinct yellow; wezterm maps yellow onto orange too
          yellow = nerv.focused.orange;
          peach = nerv.focused.orange;
          red = nerv.focused.red;
          blue = nerv.focused.blue;
          teal = nerv.focused.teal;
        };
      };

      advanced = {
        # Herdr caps scrollback by bytes, not lines; this is roughly 50000 lines
        scrollback_limit_bytes = 50000000;
      };
    };
  };

  programs.fish.interactiveShellInit = ''
    # The patched tab list falls back to the terminal title for unnamed tabs, so idle prompts keep showing the last command
    function fish_title
      if set -q argv[1]
        echo -- $argv[1]
      else if set -q history[1]
        echo -- $history[1]
      else
        prompt_pwd
      end
    end

    # Every wezterm OS window attaches to herdr's default session, and each client views its own space and tab; skip inside herdr and Claude Code
    if not set -q HERDR_ENV; and not set -q CLAUDECODE
      exec ${sessionExec} default
    end
  '';
}
