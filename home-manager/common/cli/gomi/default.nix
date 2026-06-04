{
  config,
  pkgs,
  ...
}:
let
  # `-G` は BSD/macOS では色付け、GNU/Linux ではグループ列省略を意味する
  directoryCommand =
    if pkgs.stdenv.isLinux then
      "ls -F -1 -A --color=always"
    else
      "ls -GF -1 -A --color=always";
in
{
  home.packages = [ pkgs.gomi ];

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
        directory_command: ls -GF -1 -A --color=always
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
