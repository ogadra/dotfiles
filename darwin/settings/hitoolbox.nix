{ ... }:
let
  macSKKBundleId = "net.mtgto.inputmethod.macSKK";

  # macSKKは入力モードごとに別々の入力ソースとしてmacOSに登録される
  macSKKInputSource = mode: {
    "Bundle ID" = macSKKBundleId;
    "Input Mode" = "${macSKKBundleId}.${mode}";
    InputSourceKind = "Input Mode";
  };

  # 絵文字と記号ビューア・長押し入力・50音パレット。入力メニューには出ないが
  # 有効にしておかないと該当機能が使えなくなるので必ず含める
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
    # Fnキーの動作
    # "Do Nothing" / "Change Input Source" / "Show Emoji & Symbols" / "Start Dictation"
    AppleFnUsageType = "Do Nothing";
  };

  system.defaults.CustomUserPreferences."com.apple.HIToolbox" = {
    # 使用する入力ソース。ことえりは使わないので含めない。
    # macSKKのasciiを有効にしないとIMEが起動するたびにひらがなから始まってしまう
    AppleEnabledInputSources = nonKeyboardInputSources ++ [
      (macSKKInputSource "ascii")
      (macSKKInputSource "hiragana")
    ];

    # 起動時に選択される入力ソース。ascii (直接入力) にすることで英語から始まる
    AppleSelectedInputSources = [
      {
        "Bundle ID" = "com.apple.PressAndHold";
        InputSourceKind = "Non Keyboard Input Method";
      }
      (macSKKInputSource "ascii")
    ];
  };
}
