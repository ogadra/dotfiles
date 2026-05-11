let
  mkScript = src: {
    source = src;
    executable = true;
  };
in
{
  hooks = {
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
            # ファイル末尾が改行で終わっていなければ改行を1つ追記する。
            command = ''FILE_PATH=$(jq -r '.tool_input.file_path') && [ -n "$(tail -c1 "$FILE_PATH")" ] && echo >> "$FILE_PATH"'';
          }
        ];
      }
    ];
    PreToolUse = [
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = "$HOME/.claude/scripts/pre-bash.sh";
          }
        ];
      }
    ];
  };

  scripts = {
    ".claude/scripts/pre-bash.sh" = mkScript ./scripts/pre-bash.sh;
    ".claude/scripts/git/check.sh" = mkScript ./scripts/git/check.sh;
    ".claude/scripts/git/block-default-push.sh" = mkScript ./scripts/git/block-default-push.sh;
    ".claude/scripts/git/block-no-verify.sh" = mkScript ./scripts/git/block-no-verify.sh;
  };
}
