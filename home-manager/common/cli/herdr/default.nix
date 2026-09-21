{ pkgs, profile, ... }:
let
  nerv = import ../../theme/nerv.nix;

  # Herdr cannot dim inactive panes, so the unfocused pane border sits well
  # below dimOrange to let the accent-colored focused border stand out
  fadedOrange = "#6b4126";

  # Emit a tab-bar git segment only when the focused pane is inside a repo.
  # Herdr strips escape sequences from command entries, so the output is plain text.
  gitSegment = pkgs.writeShellScript "herdr-git-segment" ''
    cd "$HERDR_ACTIVE_PANE_CWD" 2>/dev/null || exit 0
    branch=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
    [ -n "$branch" ] || exit 0
    printf '%s\n' "$branch"
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

        # prefix+w matches the old tmux kill-window, so the workspace picker
        # moves aside and rename-workspace vacates the slot it lands on
        close_tab = [
          "prefix+w"
          "prefix+shift+x"
        ];
        workspace_picker = "prefix+shift+w";
        rename_workspace = "prefix+shift+e";

        # tmux split keys alongside the herdr defaults
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

        # tmux's prefix ] and prefix = have no herdr counterpart: copies land in
        # the system clipboard, so wezterm pastes them and prefix+e opens the
        # scrollback in $EDITOR
      };

      ui = {
        copy_on_select = true;
        mouse_scroll_lines = 2;
        # wezterm's new-tab key expects a tab to appear without a name prompt
        prompt_new_tab_name = false;

        # Mirrors the old tmux status-right
        tab_bar_right = [
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
        ];
        tab_bar_right_separator = " │ ";
      };

      theme = {
        # Fall back to the wezterm palette for tokens that are not overridden
        name = "terminal";
        custom = {
          accent = nerv.orange;
          panel_bg = nerv.deepBlack;
          sidebar_bg = nerv.deepBlack;
          active_row_bg = nerv.black;
          selection_bg = nerv.dimOrange;
          surface0 = nerv.black;
          surface1 = nerv.dimOrange;
          surface_dim = nerv.deepBlack;
          overlay0 = fadedOrange;
          overlay1 = nerv.orange;
          text = nerv.orange;
          subtext0 = nerv.dimOrange;
          mauve = nerv.purple;
          green = nerv.green;
          # NERV has no distinct yellow; wezterm maps yellow onto orange too
          yellow = nerv.orange;
          peach = nerv.orange;
          red = nerv.red;
          blue = nerv.blue;
          teal = nerv.teal;
        };
      };

      advanced = {
        # Herdr caps scrollback by bytes; roughly the old 50000-line tmux limit
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
      command herdr tab rename "$HERDR_TAB_ID" "$name"
    end

    # Attach every wezterm OS window to the one shared session; skip inside herdr and Claude Code
    if status is-interactive; and not set -q HERDR_ENV; and not set -q CLAUDECODE
      exec ${pkgs.herdr}/bin/herdr
    end

    if set -q HERDR_ENV
      __herdr_rename_tab
    end
  '';
}
