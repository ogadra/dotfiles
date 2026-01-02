{ ... }:
{
  programs.fish.interactiveShellInit = ''
    # Color settings
    set -U fish_color_autosuggestion brblack
    set -U fish_color_cancel -r
    set -U fish_color_command normal
    set -U fish_color_comment red
    set -U fish_color_cwd green
    set -U fish_color_cwd_root red
    set -U fish_color_end green
    set -U fish_color_error brred
    set -U fish_color_escape brcyan
    set -U fish_color_history_current --bold
    set -U fish_color_host normal
    set -U fish_color_host_remote yellow
    set -U fish_color_normal normal
    set -U fish_color_operator brcyan
    set -U fish_color_param cyan
    set -U fish_color_quote yellow
    set -U fish_color_redirection cyan --bold
    set -U fish_color_search_match white --background=brblack --bold
    set -U fish_color_selection white --background=brblack --bold
    set -U fish_color_status red
    set -U fish_color_user brgreen
    set -U fish_color_valid_path --underline
    set -U fish_key_bindings fish_default_key_bindings
    set -U fish_pager_color_completion normal
    set -U fish_pager_color_description yellow -i
    set -U fish_pager_color_prefix normal --bold --underline
    set -U fish_pager_color_progress brwhite --background=cyan --bold
    set -U fish_pager_color_selected_background -r
    set -U fish_prompt_pwd_dir_length 0
  '';
}
