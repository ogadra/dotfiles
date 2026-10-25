{ ... }:
{
  # Pins KWin monitor layout left to right as DP-6, DP-5, HDMI-A-3; the 4K panels use 120% scale so each is 3200 logical px wide
  xdg.configFile."kwinoutputconfig.json".source = ./kwinoutputconfig.json;
}
