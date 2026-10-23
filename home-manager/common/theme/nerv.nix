# NERV HUD palette. Single source for every module that paints in these colors.
{
  focused = {
    orange = "#ff8a25";
    dimOrange = "#935c37";
    black = "#1a1a1a";
    deepBlack = "#0a0a0a";
    white = "#ffffff";
    green = "#25ef25";
    red = "#ef2525";
    purple = "#b837ff";
    teal = "#37dddd";
    blue = "#7878ff";
  };

  unfocused = {
    orange = "#caa153";
    dimOrange = "#8c6b2e";
    black = "#242424";
    deepBlack = "#141414";
    white = "#d0d0d0";
    green = "#43b153";
    red = "#b85443";
    purple = "#b243c1";
    teal = "#4397a6";
    blue = "#6655ca";
  };

  # Row backgrounds that tell spaces apart: Evangelion unit colors sampled by uto-room.com/color/character/eva, darkened to a 0x3a peak channel so the orange text keeps its contrast
  spaceTints = [
    # Unit-00 orange yellow #f0941b
    "#3a2407"
    # Unit-01 purple #65508e
    "#29213a"
    # Unit-01 green #6eb72d
    "#233a0e"
    # Unit-02 red #a62125
    "#3a0c0d"
    # Mark.06 dark blue #013f69
    "#01233a"
    # Unit-08 pink #f5aecd
    "#3a2931"
  ];
}
