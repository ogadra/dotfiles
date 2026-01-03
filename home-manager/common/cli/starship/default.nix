{ ... }:
{
  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      format = "[](fg:#0a0a0a bg:#f07820)$username[](fg:#f07820 bg:#1a1a1a)$directory[ ](fg:#1a1a1a)\n$character";

      # === who/where ===
      username = {
        show_always = true;
        format = "[ $user]($style)";
        style_user = "#1a1a1a bg:#f07820";
      };

      # === path ===
      directory = {
        home_symbol = "~";
        truncation_length = 0;
        truncate_to_repo = false;
        style = "#f07820 bg:#1a1a1a";
        format = "[ $path ]($style)[$read_only]($read_only_style)";
      };

      # === prompt symbol ===
      character = {
        success_symbol = "[\\$](#f07820) ";
        error_symbol = "[\\$](#ff3030) ";
      };
    };
  };
}
