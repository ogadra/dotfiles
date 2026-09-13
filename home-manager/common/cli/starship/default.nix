{ ... }:
{
  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      format = "$username[](fg:yellow bg:black)$directory[ ](fg:black)";

      # === who/where ===
      username = {
        show_always = true;
        format = "[ $user]($style)";
        style_user = "black bg:yellow";
      };

      # === path ===
      directory = {
        home_symbol = "~";
        truncation_length = 0;
        truncate_to_repo = false;
        style = "yellow bg:black";
        format = "[ $path ]($style)[$read_only]($read_only_style)";
      };
    };
  };
}
