{ pkgs, ... }:
{
  home.file.".config/fish/sounds/done.mp3".source = ../../../sounds/stop.mp3;

  programs.fish.interactiveShellInit = ''
    function ghq-fzf
      set src (ghq list | fzf --preview "sh -c 'bat --color=always --style=header,grid --line-range :80 \$(ghq root)/\$1/README.* 2>/dev/null' _ {}")
      if test -n "$src"
        cd (ghq root)/$src
      end
    end

    bind \cg ghq-fzf

    # Rings once a long job is over
    function done
      mpv --no-terminal --volume=30 ~/.config/fish/sounds/done.mp3 </dev/null >/dev/null 2>&1 &
      disown
    end

    # herdr drops the OSC 133 marks fish emits, so the starship prompt line is the only boundary left in the scrollback
    function copy-last
      if not set -q HERDR_PANE_ID
        printf 'copy-last: not inside a herdr pane\n' >&2
        return 1
      end
      # herdr returns at most 1000 lines, so a longer output loses its head
      set -l lines (herdr pane read $HERDR_PANE_ID --source recent-unwrapped --lines 1000)
      set -l prompts
      for i in (seq (count $lines))
        if string match -qr '^ \S+\x{e0bc} .* \x{e0bc}' -- $lines[$i]
          set -a prompts $i
        end
      end
      # The last prompt is the one copy-last runs from; the one before it holds the previous command
      if test (count $prompts) -lt 2
        printf 'copy-last: no previous command in the scrollback\n' >&2
        return 1
      end
      set -l first (math $prompts[-2] + 1)
      # Skips the blank line starship's add_newline prints above every prompt
      set -l last (math $prompts[-1] - 2)
      # fish reverses a range whose end is below its start, so an empty output needs its own check
      if test $last -lt $first
        printf 'copy-last: the previous command printed nothing\n' >&2
        return 1
      end
      printf '%s\n' $lines[$first..$last] | ${
        if pkgs.stdenv.hostPlatform.isLinux then "wl-copy" else "pbcopy"
      }
    end

    # Alt chords switch herdr tabs, and ctrl-o is the one Ctrl letter left free by fish, wezterm, and herdr; the repaint redraws a prompt that an error message overwrote
    bind \co 'copy-last; commandline -f repaint'
  '';
}
