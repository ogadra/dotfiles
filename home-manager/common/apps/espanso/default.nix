{ ... }:
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
  };
}
