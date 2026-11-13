{
  config,
  lib,
  pkgs,
  ...
}:
let
  # `-G` colorizes on BSD and macOS but drops the group column on GNU and Linux
  directoryCommand =
    if pkgs.stdenv.hostPlatform.isLinux then
      "ls -F -1 -A --color=always"
    else
      "ls -GF -1 -A --color=always";
  # `-f` skips the confirmation prompt, which would block an unattended run
  pruneCommand = [
    "${pkgs.gomi}/bin/gomi"
    "--prune=7d"
    "-f"
  ];
in
{
  home.packages = [ pkgs.gomi ];

  # A Persistent timer catches up on a run missed while the machine was off
  systemd.user.services.gomi-prune = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit.Description = "Remove gomi trash older than 7 days";
    Service = {
      Type = "oneshot";
      ExecStart = lib.escapeShellArgs pruneCommand;
    };
  };
  systemd.user.timers.gomi-prune = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit.Description = "Remove gomi trash older than 7 days daily";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # launchd runs a calendar job missed during sleep on wake, but not one missed while powered off, so also run at login
  launchd.agents.gomi-prune = lib.mkIf (!pkgs.stdenv.hostPlatform.isLinux) {
    enable = true;
    config = {
      ProgramArguments = pruneCommand;
      RunAtLoad = true;
      StartCalendarInterval = [
        {
          Hour = 12;
          Minute = 0;
        }
      ];
    };
  };

  xdg.configFile."gomi/config.yaml".text = ''
    core:
      trash:
        strategy: auto
        home_fallback: true
        gomi_dir: ${config.home.homeDirectory}/.gomi
        forbidden_paths:
        - $HOME/.local/share/Trash
        - $HOME/.trash
        - $XDG_DATA_HOME/Trash
        - /tmp/Trash
        - /var/tmp/Trash
        - $HOME/.gomi
        - /
        - /etc
        - /usr
        - /var
        - /bin
        - /sbin
        - /lib
        - /lib64
      restore:
        confirm: true
        verbose: true
      permanent_delete:
        enable: false
      trash_dir: ""
    ui:
      density: spacious
      style:
        list_view:
          indent_on_select: true
          cursor: '#AD58B4'
          selected: '#5FB458'
          filter_match: '#F39C12'
          filter_prompt: '#7AA2F7'
        detail_view:
          border: '#EEEEDD'
          info_pane:
            deleted_from:
              fg: '#EEEEEE'
              bg: '#1C1C1C'
            deleted_at:
              fg: '#EEEEEE'
              bg: '#1C1C1C'
          preview_pane:
            border: '#3C3C3C'
            size:
              fg: '#EEEEDD'
              bg: '#3C3C3C'
            scroll:
              fg: '#EEEEDD'
              bg: '#3C3C3C'
        deletion_dialog: '#FF007F'
      exit_message: ""
      preview:
        syntax_highlight: true
        colorscheme: nord
        directory_command: ${directoryCommand}
      paginator_type: dots
    history:
      include:
        within_days: 365
      exclude:
        files:
        - .DS_Store
        patterns: []
        globs: []
        size:
          min: 0KB
          max: 10GB
    logging:
      enabled: true
      level: debug
      rotation:
        max_size: 10MB
        max_files: 3
  '';
}
