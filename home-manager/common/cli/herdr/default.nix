{
  pkgs,
  lib,
  config,
  profile,
  ...
}:
let
  nerv = import ../../theme/nerv.nix;

  herdrBin = "${config.programs.herdr.package}/bin/herdr";

  # /proc/stat counts since boot, so CPU is the busy share of a one-second delta; awk is a parameter because the remote host has no Nix store path
  linuxLoad = awk: ''
    read -r _ u1 n1 s1 i1 w1 q1 r1 _ </proc/stat
    sleep 1
    read -r _ u2 n2 s2 i2 w2 q2 r2 _ </proc/stat
    busy=$(((u2 + n2 + s2 + q2 + r2) - (u1 + n1 + s1 + q1 + r1)))
    idle=$(((i2 + w2) - (i1 + w1)))
    cpu=$((busy * 100 / (busy + idle)))
    mem=$(${awk} '/^MemTotal/ { t = $2 } /^MemAvailable/ { a = $2 } END { printf "%d", (t - a) * 100 / t }' /proc/meminfo)
    disk=$(df -P "$HOME" | ${awk} 'NR == 2 { sub(/%/, "", $5); print $5 }')
    printf 'CPU %s%%  MEM %s%%  DISK %s%%\n' "$cpu" "$mem" "$disk"
  '';

  # ps reports decayed per-process averages, so summing them avoids top's multi-second sampling; memory_pressure's free share matches Activity Monitor's pressure gauge
  darwinLoad = ''
    ncpu=$(/usr/sbin/sysctl -n hw.ncpu)
    cpu=$(/bin/ps -A -o %cpu= | /usr/bin/awk -v n="$ncpu" '{ s += $1 } END { printf "%d", s / n + 0.5 }')
    mem=$(/usr/bin/memory_pressure | /usr/bin/awk '/free percentage/ { sub(/%/, "", $NF); print 100 - $NF }')
    disk=$(/bin/df -P "$HOME" | /usr/bin/awk 'NR == 2 { sub(/%/, "", $5); print $5 }')
    printf 'CPU %s%%  MEM %s%%  DISK %s%%\n' "$cpu" "$mem" "$disk"
  '';

  # Fed to the remote sh over stdin, so it picks the body by the remote's own OS
  remoteLoad = pkgs.writeText "herdr-remote-load" ''
    case "$(uname)" in
    Darwin)
    ${darwinLoad}
      ;;
    *)
    ${linuxLoad "awk"}
      ;;
    esac
  '';

  # Rebuilds the active pane's ssh invocation without its remote command; `dest` prints the destination, `exec CMD` runs CMD there
  sshRun = pkgs.writeShellScript "herdr-ssh-run" ''
    set -u
    mode=$1
    shift
    pid=''${HERDR_ACTIVE_PANE_SSH_PID:?}
    ${
      if pkgs.stdenv.hostPlatform.isLinux then
        ''mapfile -d "" -t argv </proc/"$pid"/cmdline''
      else
        # macOS has no /proc; ps joins argv with spaces, so arguments that contain spaces split apart
        ''read -r -a argv <<<"$(/bin/ps -p "$pid" -o args=)"''
    }
    opts=()
    dest=
    set -- "''${argv[@]:1}" "$@"
    while [ $# -gt 0 ]; do
      case $1 in
      --)
        dest=''${2:-}
        shift 2
        break
        ;;
      -*)
        opts+=("$1")
        flags=''${1#-}
        # These are ssh's options that take a value; one that ends the cluster takes the next argument
        while [ -n "$flags" ]; do
          flag=''${flags:0:1}
          flags=''${flags:1}
          case $flag in
          [BbcDEeFIiJLlmOoPpQRSWw])
            if [ -z "$flags" ]; then
              shift
              opts+=("''${1:-}")
            fi
            break
            ;;
          esac
        done
        shift
        ;;
      *)
        dest=$1
        shift
        break
        ;;
      esac
    done
    [ -n "$dest" ] || exit 1
    if [ "$mode" = dest ]; then
      printf '%s\n' "$dest"
      exit
    fi
    # The status commands' own connections share one master per host, so polling every second does not log in again each time
    control_dir="''${XDG_RUNTIME_DIR:-''${TMPDIR:-/tmp}}/herdr-ssh"
    mkdir -p -m 700 "$control_dir"
    # Only the arguments the pane's ssh received after its destination are dropped, which are the remote command
    exec ${pkgs.openssh}/bin/ssh -o BatchMode=yes -o ConnectTimeout=3 -o ControlMaster=auto -o "ControlPath=$control_dir/%C" -o ControlPersist=60 "''${opts[@]}" "$dest" "''${@: -1}"
  '';

  # Herdr strips escape sequences from command entries, so emit plain text; storage reads the home volume because the macOS root is the sealed system snapshot
  loadSegment = pkgs.writeShellScript "herdr-load-segment" ''
    if [ -n "''${HERDR_ACTIVE_PANE_SSH_PID:-}" ]; then
      # A host that needs a password cannot answer a BatchMode poll, so the segment stays empty and herdr hides it
      exec ${sshRun} exec 'sh -s' <${remoteLoad}
    fi
    ${if pkgs.stdenv.hostPlatform.isLinux then linuxLoad "${pkgs.gawk}/bin/awk" else darwinLoad}
  '';

  # Prints nothing outside ssh, so herdr drops the segment along with its separator
  sshModeSegment = pkgs.writeShellScript "herdr-ssh-mode-segment" ''
    [ -z "''${HERDR_ACTIVE_PANE_SSH_PID:-}" ] || printf '[SSH MODE]\n'
  '';

  # The remote's own name when it answers, else the destination the pane's ssh was given
  hostSegment = pkgs.writeShellScript "herdr-host-segment" ''
    if [ -n "''${HERDR_ACTIVE_PANE_SSH_PID:-}" ]; then
      # A name only changes with the ssh process, so it is cached per pid instead of asked every poll; the destination fallback is not cached so a later poll can still reach the host
      cache="''${XDG_RUNTIME_DIR:-''${TMPDIR:-/tmp}}/herdr-ssh/host-$HERDR_ACTIVE_PANE_SSH_PID"
      if [ -s "$cache" ]; then
        cat "$cache"
      elif name=$(${sshRun} exec 'hostname -s 2>/dev/null || uname -n' </dev/null) && [ -n "$name" ]; then
        printf '%s\n' "$name" | tee "$cache"
      else
        ${sshRun} dest
      fi
      exit
    fi
    printf '%s\n' ${lib.escapeShellArg profile}
  '';

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
        # wezterm reports these chords in kitty form, since a legacy Alt+Tab arrives as an ESC that herdr may read as its own key
        next_workspace = "alt+tab";
        previous_workspace = "alt+shift+tab";
        # Needs patches/sidebar-tabs.patch, upstream accepts only 1..9; one keyboard row per list, and the sidebar shows each key under its row's status icon
        switch_workspace = map (key: "alt+${key}") (lib.stringToCharacters "qwertyuiop");
        switch_tab = map (key: "alt+${key}") (lib.stringToCharacters "asdfghjkl");
        focus_agent = map (key: "alt+${key}") (lib.stringToCharacters "zxcvbnm");

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
            command = "${sshModeSegment}";
            # 1 is the shortest interval herdr accepts, in whole seconds
            interval_seconds = 1;
            timeout_seconds = 1;
          }
          {
            type = "command";
            command = "${loadSegment}";
            # Linux samples /proc/stat for a second, so the next poll starts as soon as one finishes
            interval_seconds = 1;
            # A first ssh connection can take up to its 3-second ConnectTimeout on top of the sample
            timeout_seconds = 4;
          }
          {
            type = "command";
            command = "${hostSegment}";
            interval_seconds = 1;
            # Leaves room for the 3-second ConnectTimeout before falling back to the destination name
            timeout_seconds = 4;
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

    # Every wezterm OS window attaches to herdr's default session, and each client views its own space and tab; skip inside herdr, Claude Code, and SSH (the remote herdr would nest inside the local pane)
    if not set -q HERDR_ENV; and not set -q CLAUDECODE; and not set -q SSH_CONNECTION
      exec ${sessionExec} default
    end
  '';
}
