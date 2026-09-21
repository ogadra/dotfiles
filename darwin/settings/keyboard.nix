{ ... }:
{
  system.defaults.NSGlobalDomain = {
    # Lower is faster, 10 is the floor
    InitialKeyRepeat = 15;

    # Lower is faster, 1 is the floor
    KeyRepeat = 2;

    # true opens the accent panel on hold, false repeats the key instead
    ApplePressAndHoldEnabled = false;

    NSAutomaticCapitalizationEnabled = false;

    # Substitutes an em dash for --
    NSAutomaticDashSubstitutionEnabled = false;

    # Inserts a period on a double space
    NSAutomaticPeriodSubstitutionEnabled = false;

    # Substitutes curly quotes for straight ones
    NSAutomaticQuoteSubstitutionEnabled = false;

    NSAutomaticSpellingCorrectionEnabled = false;
  };
}
