{ ... }:
{
  # Pins KWin monitor layout: DP-6 left of DP-5, both 3840x2160 at 120% scale so each is 3200 logical px wide
  xdg.configFile."kwinoutputconfig.json".source = ./kwinoutputconfig.json;
}
