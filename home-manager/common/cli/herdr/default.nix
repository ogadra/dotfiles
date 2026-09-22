{
  pkgs,
  config,
  profile,
  ...
}:
let
  nerv = import ../../theme/nerv.nix;

  herdrBin = "${config.programs.herdr.package}/bin/herdr";

  # Herdr strips escape sequences from command entries, so emit plain text
  gitSegment = pkgs.writeShellScript "herdr-git-segment" ''
    cd "$HERDR_ACTIVE_PANE_CWD" 2>/dev/null || exit 0
    branch=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
    [ -n "$branch" ] || exit 0
    printf '%s\n' "$branch"
  '';

  # Publish the session name as a wezterm user var so its keybinds can drive this window's session; OSC 1337 takes a base64 value
  sessionExec = pkgs.writeShellScript "herdr-session-exec" ''
    printf '\033]1337;SetUserVar=herdr_session=%s\007' "$(printf %s "$1" | ${pkgs.coreutils}/bin/base64)"
    exec ${herdrBin} --session "$1"
  '';

  # One session per wezterm OS window: the git segment reads the session-wide active pane
  windowSession = pkgs.writeShellScript "herdr-window-session" ''
    set -u
    lock_dir="''${XDG_RUNTIME_DIR:-''${TMPDIR:-/tmp}}/herdr-windows"
    mkdir -p "$lock_dir"
    slot=1
    while :; do
      ${pkgs.flock}/bin/flock -n -E 66 "$lock_dir/$slot" ${sessionExec} "window$slot"
      status=$?
      # 66 is flock's conflict code, so only a slot another window holds continues the search
      [ "$status" -eq 66 ] || exit "$status"
      slot=$((slot + 1))
    done
  '';
in
{
  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;

      terminal = {
        # New panes, tabs, and workspaces inherit the source pane's directory
        new_cwd = "follow";
      };

      keys = {
        prefix = "ctrl+q";

        # close_tab takes prefix+w, so the picker and rename_workspace each shift one slot
        close_tab = [
          "prefix+w"
          "prefix+shift+x"
        ];
        workspace_picker = "prefix+shift+w";
        rename_workspace = "prefix+shift+e";

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

        tab_bar_right = [
          # Separators land only between segments, so literals at both ends close the strip
          {
            type = "text";
            text = " ";
          }
          {
            type = "command";
            command = "${gitSegment}";
          }
          {
            type = "text";
            text = profile;
          }
          {
            type = "datetime";
            format = "%H:%M:%S";
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
    # Name the herdr tab with the wezterm-style display path (repo-relative or ~-shortened)
    function __herdr_rename_tab --on-variable PWD
      set -q HERDR_TAB_ID; or return
      set -l path "$PWD"
      set -l git_root (command git rev-parse --show-toplevel 2>/dev/null)
      set -l name
      if test -n "$git_root"
        set -l repo (basename "$git_root")
        if test "$path" = "$git_root"
          set name "$repo"
        else
          set name "$repo"/(string sub --start (math (string length "$git_root") + 2) -- "$path")
        end
      else
        set name (string replace --regex "^$HOME" "~" -- "$path")
      end
      ${herdrBin} tab rename "$HERDR_TAB_ID" "$name" >/dev/null 2>&1
    end

    # Give every wezterm OS window its own herdr session; skip inside herdr and Claude Code
    if not set -q HERDR_ENV; and not set -q CLAUDECODE
      exec ${windowSession}
    end

    if set -q HERDR_ENV
      __herdr_rename_tab
    end
  '';
}
