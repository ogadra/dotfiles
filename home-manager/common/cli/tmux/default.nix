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

  idleLook = "#[fg=${black}]#[bg=${orange}]#[bold]";
  hintOpen = "#[fg=${black}]#[bg=${orange}]#[nobold]${solidLeft}";
  hintLabel = "#[fg=${orange}]#[bg=${black}]#[bold]";
  hintBody = "#[fg=${orange}]#[bg=${black}]#[nobold]";
  hintClose = "#[fg=${black}]#[bg=${orange}]#[nobold]${solidRight}";

  hintKeysFull = "c:window w:閉じる n/p:前後 %:左右 \":上下 o:pane z:zoom [:copy ]:貼付 =:履歴 s:session d:detach";
  hintKeysShort = "c:window w:閉じる n/p:前後 %:左右 \":上下 [:copy";

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

      # Scroll 2 lines per wheel notch instead of the default 5
      bind -T copy-mode WheelUpPane send-keys -X -N 2 scroll-up
      bind -T copy-mode WheelDownPane send-keys -X -N 2 scroll-down

      # Keep the selection visible after releasing the mouse instead of copying-and-cancelling
      bind -T copy-mode MouseDragEnd1Pane send-keys -X copy-selection-no-clear

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

      # While the prefix is pending the whole bar becomes the key hint
      set -g @bar-hint-full '${hintOpen}${hintLabel} C-q ${hintBody} ${hintKeysFull} ${hintClose}'
      set -g @bar-hint-short '${hintOpen}${hintLabel} C-q ${hintBody} ${hintKeysShort} ${hintClose}'
      set -g @bar-brand '${idleLook} TERMINAL '
      set -g @bar-tab-current "#[fg=${black},bg=${orange}] ${solidLeft}#[fg=${orange},bg=${black}] #W #[fg=${black},bg=${orange}]${solidRight}"
      set -g @bar-tab "#[fg=${deepBlack},bg=${orange}] ${solidLeft}#[fg=${dimOrange},bg=${deepBlack}] #W #[fg=${deepBlack},bg=${orange}]${solidRight}"
      set -g @bar-right "#(${gitSegment} '#{pane_current_path}')#[fg=${black},bg=${orange}]${solidLeft}#[fg=${orange},bg=${black}] ${profile} ${solidLeft}#[fg=${black},bg=${orange}]${solidLeft}#[fg=${orange},bg=${black}] %H:%M:%S ${solidLeft}#[fg=${black},bg=${orange}] "

      set -g status-left-length 200
      set -g status-left '#{?client_prefix,#{?#{e|>=:#{client_width},105},#{@bar-hint-full},#{@bar-hint-short}},#{@bar-brand}}'

      # Window tabs: black inset with slanted edges; name is the display path set by fish
      setw -g window-status-current-format '#{?client_prefix,,#{T:@bar-tab-current}}'
      setw -g window-status-format '#{?client_prefix,,#{T:@bar-tab}}'

      set -g status-right-length 100
      set -g status-right '#{?client_prefix,,#{T:@bar-right}}'
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
