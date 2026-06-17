{ pkgs, profile, ... }:
let
  # NERV palette (kept in sync with wezterm color.nix)
  orange = "#f07820";
  black = "#1a1a1a";
  deepBlack = "#0a0a0a";
  dimOrange = "#805030";

  # Powerline triangles matching wezterm's tab-bar (ple_lower_right / ple_upper_left)
  solidLeft = ""; # U+E0BA
  solidRight = ""; # U+E0BC

  # Emit a right-status git segment only when the path is inside a repo
  gitSegment = pkgs.writeShellScript "tmux-git-segment" ''
    cd "$1" 2>/dev/null || exit 0
    branch=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
    [ -n "$branch" ] || exit 0
    printf '#[fg=${black},bg=${orange}]${solidLeft}#[fg=${orange},bg=${black}] %s ${solidLeft}' "$branch"
  '';
in
{
  programs.tmux = {
    enable = true;
    prefix = "C-q";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "emacs";
    historyLimit = 50000;
    terminal = "tmux-256color";
    extraConfig = ''
      set -g pane-base-index 1
      set -ga terminal-overrides ",*256col*:Tc"

      # Claude Code clamps its color depth to 256 when $TMUX is set; opt out to keep truecolor
      set-environment -g CLAUDE_CODE_TMUX_TRUECOLOR 1

      # Delegation targets sent by wezterm after the prefix
      bind c new-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind w kill-window
      bind n next-window
      bind p previous-window

      # NERV-style status line (mirrors the wezterm tab-bar look)
      set -g status on
      set -g status-position top
      set -g status-interval 1
      set -g status-justify left
      set -g status-style "bg=${orange},fg=${black}"
      setw -g automatic-rename off
      set -g window-status-separator ""

      set -g status-left-length 20
      set -g status-left "#[fg=${black},bg=${orange},bold] TERMINAL "

      # Window tabs: black inset with slanted edges; name is the display path set by fish
      setw -g window-status-current-format "#[fg=${black},bg=${orange}] ${solidLeft}#[fg=${orange},bg=${black}] #W #[fg=${black},bg=${orange}]${solidRight}"
      setw -g window-status-format "#[fg=${deepBlack},bg=${orange}] ${solidLeft}#[fg=${dimOrange},bg=${deepBlack}] #W #[fg=${deepBlack},bg=${orange}]${solidRight}"

      set -g status-right-length 100
      set -g status-right "#(${gitSegment} '#{pane_current_path}')#[fg=${black},bg=${orange}]${solidLeft}#[fg=${orange},bg=${black}] ${profile} ${solidLeft}#[fg=${black},bg=${orange}]${solidLeft}#[fg=${orange},bg=${black}] %H:%M:%S ${solidLeft}#[fg=${black},bg=${orange}] "
    '';
  };

  programs.fish.interactiveShellInit = ''
    # Name the tmux window with the wezterm-style display path (repo-relative or ~-shortened)
    function __tmux_rename_window --on-variable PWD
      set -q TMUX; or return
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
      command tmux rename-window -t "$TMUX_PANE" -- "$name"
    end

    # Auto-attach a fresh tmux session per OS window; skip inside tmux and Claude Code
    if status is-interactive; and not set -q TMUX; and not set -q CLAUDECODE
      exec ${pkgs.tmux}/bin/tmux new-session
    end

    # Set the initial window name when already inside tmux
    if set -q TMUX
      __tmux_rename_window
    end
  '';
}
