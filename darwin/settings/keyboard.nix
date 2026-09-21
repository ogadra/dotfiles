{ ... }:
{
  system.defaults.NSGlobalDomain = {
    # Delay before a key starts repeating; lower is faster, 10 is the floor
    InitialKeyRepeat = 15;

    # Key repeat rate; lower is faster, 1 is the floor
    KeyRepeat = 2;

    # true opens the accent panel on hold, false repeats the key instead
    ApplePressAndHoldEnabled = false;

    # Capitalize the first word of a sentence
    NSAutomaticCapitalizationEnabled = false;

    # Substitute an em dash for --
    NSAutomaticDashSubstitutionEnabled = false;

    # Insert a period on a double space
    NSAutomaticPeriodSubstitutionEnabled = false;

    # Substitute curly quotes for straight ones
    NSAutomaticQuoteSubstitutionEnabled = false;

    # Correct spelling automatically
    NSAutomaticSpellingCorrectionEnabled = false;
  };
}
