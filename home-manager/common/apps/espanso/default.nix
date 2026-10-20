{ lib, pkgs, ... }:
let
  version = "2.4.1";
  dmgUrl = "https://github.com/espanso/espanso/releases/download/v${version}/Espanso-Mac-Universal.dmg";
  dmgSha256 = "e6aee2d9446d7625e57dafc6613add21fc7c9f709ba42f08b5ada844c6f7110a";

  yaml = pkgs.formats.yaml { };

  # Disable the search bar popup so its shortcut stays free for the app launcher; accepts a key combo like "ALT+SPACE" or "off"
  configs.default.search_shortcut = "off";

  matches.base.matches = [
    {
      trigger = ";c";
      replace = "continue";
    }
    {
      trigger = ":+1:";
      replace = "👍";
    }
    {
      trigger = ":-1:";
      replace = "👎";
    }
    {
      trigger = ":bangbang:";
      replace = "‼️";
    }
    {
      trigger = ":birthday:";
      replace = "🎂";
    }
    {
      trigger = ":boom:";
      replace = "💥";
    }
    {
      trigger = ":bow:";
      replace = "🙇";
    }
    {
      trigger = ":car:";
      replace = "🚗";
    }
    {
      trigger = ":confetti_ball:";
      replace = "🎊";
    }
    {
      trigger = ":cry:";
      replace = "😢";
    }
    {
      trigger = ":dotted_line_face:";
      replace = "🫥";
    }
    {
      trigger = ":eye:";
      replace = "👁️";
    }
    {
      trigger = ":eyes:";
      replace = "👀";
    }
    {
      trigger = ":fire:";
      replace = "🔥";
    }
    {
      trigger = ":first:";
      replace = "このわたしがッ！最初のコミットを手にしたぞッ！";
    }
    {
      trigger = ":interrobang:";
      replace = "⁉️";
    }
    {
      trigger = ":memo:";
      replace = "📝";
    }
    {
      trigger = ":muscle:";
      replace = "💪";
    }
    {
      trigger = ":ng:";
      replace = "🆖";
    }
    {
      trigger = ":o:";
      replace = "⭕";
    }
    {
      trigger = ":ok:";
      replace = "🆗";
    }
    {
      trigger = ":pie:";
      replace = "🥧";
    }
    {
      trigger = ":pray:";
      replace = "🙏";
    }
    {
      trigger = ":smile:";
      replace = "😄";
    }
    {
      trigger = ":sob:";
      replace = "😭";
    }
    {
      trigger = ":sweat:";
      replace = "😓";
    }
    {
      trigger = ":sweat_smile:";
      replace = "😅";
    }
    {
      trigger = ":tada:";
      replace = "🎉";
    }
    {
      trigger = ":thinking_face:";
      replace = "🤔";
    }
    {
      trigger = ":up:";
      replace = "🆙";
    }
    {
      trigger = ":x:";
      replace = "❌";
    }
    {
      trigger = "cosnt";
      replace = "const";
    }
  ];
in
lib.mkMerge [
  (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    services.espanso = {
      enable = true;

      # KDE Plasma 6 hosts run Wayland only, so skip building the X11 variant
      x11Support = false;

      inherit configs matches;
    };
  })
  (lib.mkIf (!pkgs.stdenv.hostPlatform.isLinux) {
    xdg.configFile =
      lib.mapAttrs' (name: value: {
        name = "espanso/config/${name}.yml";
        value.source = yaml.generate "${name}.yml" value;
      }) configs
      // lib.mapAttrs' (name: value: {
        name = "espanso/match/${name}.yml";
        value.source = yaml.generate "${name}.yml" value;
      }) matches;

    home.activation.installEspanso = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "/Applications/Espanso.app" ]; then
        _dmg=$(mktemp /tmp/espanso-XXXXXX.dmg)
        /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
        echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { rm -f "$_dmg"; exit 1; }
        _mnt=$(/usr/bin/mktemp -d /tmp/espanso-mnt-XXXXXX)
        /usr/bin/hdiutil attach "$_dmg" -mountpoint "$_mnt" -nobrowse -quiet
        /bin/cp -R "$_mnt/Espanso.app" /Applications/
        /usr/bin/xattr -dr com.apple.quarantine /Applications/Espanso.app
        /usr/bin/hdiutil detach "$_mnt" -quiet
        rm -f "$_dmg"
      fi
    '';
  })
]
