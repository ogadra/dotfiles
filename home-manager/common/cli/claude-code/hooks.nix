{
  Notification = [
    {
      matcher = "";
      hooks = [
        {
          type = "command";
          command = "mpv --no-terminal ~/.claude/sounds/notification.mp3 &";
        }
      ];
    }
  ];
  Stop = [
    {
      matcher = "";
      hooks = [
        {
          type = "command";
          command = "mpv --no-terminal ~/.claude/sounds/stop.mp3 &";
        }
      ];
    }
  ];
  PostToolUse = [
    {
      matcher = "Write";
      hooks = [
        {
          type = "command";
          command = ''FILE_PATH=$(jq -r '.tool_input.file_path') && [ -n "$(tail -c1 "$FILE_PATH")" ] && echo >> "$FILE_PATH"'';
        }
      ];
    }
  ];
}
