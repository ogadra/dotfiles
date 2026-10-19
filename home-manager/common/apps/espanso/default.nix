{ lib, ... }:
{
  services.espanso = {
    enable = true;

    # KDE Plasma 6 hosts run Wayland only, so skip building the X11 variant; ignored on macOS
    x11Support = false;

    # Disable the search bar popup so its shortcut stays free for the app launcher; accepts a key combo like "ALT+SPACE" or "off"
    configs.default.search_shortcut = "off";

    matches.base.matches = [
      {
        trigger = ";c";
        replace = "continue";
      }
    ]
    ++ lib.mapAttrsToList (trigger: replace: { inherit trigger replace; }) {
      ":+1:" = "👍";
      ":-1:" = "👎";
      ":bangbang:" = "‼️";
      ":birthday:" = "🎂";
      ":boom:" = "💥";
      ":bow:" = "🙇";
      ":car:" = "🚗";
      ":confetti_ball:" = "🎊";
      ":cry:" = "😢";
      ":dotted_line_face:" = "🫥";
      ":eye:" = "👁️";
      ":eyes:" = "👀";
      ":fire:" = "🔥";
      ":first:" = "このわたしがッ！最初のコミットを手にしたぞッ！";
      ":interrobang:" = "⁉️";
      ":memo:" = "📝";
      ":muscle:" = "💪";
      ":ng:" = "🆖";
      ":o:" = "⭕";
      ":ok:" = "🆗";
      ":pie:" = "🥧";
      ":pray:" = "🙏";
      ":smile:" = "😄";
      ":sob:" = "😭";
      ":sweat:" = "😓";
      ":sweat_smile:" = "😅";
      ":tada:" = "🎉";
      ":thinking_face:" = "🤔";
      ":up:" = "🆙";
      ":x:" = "❌";
      "cosnt" = "const";
    };
  };
}
