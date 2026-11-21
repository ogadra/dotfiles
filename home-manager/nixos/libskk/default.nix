{ ... }:
let
  ruleName = "no-kuten";
  # Includes resolve "default/<file>" against the system libskk rules, so only the overrides live here
  keymap = mode: overrides: {
    include = [ "default/${mode}" ];
    define.keymap = overrides;
  };
  # Unbinds "\" because the stray press drops into kuten (JIS code point) entry, which is never used
  noKuten = {
    "\\" = null;
  };
  files = {
    "metadata.json" = {
      name = "No Kuten";
      description = "Default typing rule without kuten input";
    };
    "keymap/hiragana.json" = keymap "hiragana" noKuten;
    "keymap/katakana.json" = keymap "katakana" noKuten;
    "keymap/hankaku-katakana.json" = keymap "hankaku-katakana" noKuten;
    # libskk loads a keymap per input mode from the selected rule, so the latin modes are passed through as is
    "keymap/latin.json" = keymap "latin" { };
    "keymap/wide-latin.json" = keymap "wide-latin" { };
    "rom-kana/default.json" = {
      include = [ "default/default" ];
    };
  };
in
{
  xdg.configFile = builtins.listToAttrs (
    map (path: {
      name = "libskk/rules/${ruleName}/${path}";
      value.text = builtins.toJSON files.${path};
    }) (builtins.attrNames files)
  );
}
