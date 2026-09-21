{ ... }:
let
  macSKKBundleId = "net.mtgto.inputmethod.macSKK";

  # macOS registers each macSKK input mode as its own input source
  macSKKInputSource = mode: {
    "Bundle ID" = macSKKBundleId;
    "Input Mode" = "${macSKKBundleId}.${mode}";
    InputSourceKind = "Input Mode";
  };

  # The emoji viewer, press-and-hold, and kana palette never show in the input menu, yet leaving them out disables those features
  nonKeyboardInputSources = map
    (bundleId: {
      "Bundle ID" = bundleId;
      InputSourceKind = "Non Keyboard Input Method";
    })
    [
      "com.apple.CharacterPaletteIM"
      "com.apple.PressAndHold"
      "com.apple.50onPaletteIM"
    ];
in
{
  system.defaults.hitoolbox = {
    # Fn key: "Do Nothing" / "Change Input Source" / "Show Emoji & Symbols" / "Start Dictation"
    AppleFnUsageType = "Do Nothing";
  };

  system.defaults.CustomUserPreferences."com.apple.HIToolbox" = {
    # Kotoeri is left out, and macSKK's ascii mode has to be enabled or the IME starts in hiragana every time
    AppleEnabledInputSources = nonKeyboardInputSources ++ [
      (macSKKInputSource "ascii")
      (macSKKInputSource "hiragana")
    ];

    # ascii means direct input, so a session starts in English
    AppleSelectedInputSources = [
      {
        "Bundle ID" = "com.apple.PressAndHold";
        InputSourceKind = "Non Keyboard Input Method";
      }
      (macSKKInputSource "ascii")
    ];
  };
}
