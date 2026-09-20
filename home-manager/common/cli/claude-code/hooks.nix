let
  mkScript = src: {
    source = src;
    executable = true;
  };
  shared = ../../modules/llm-agent;
in
{
  hooks = {
    PermissionRequest = [
      {
        matcher = "";
        hooks = [
          {
            type = "command";
            command = "(mpv --no-terminal --volume=30 ~/.claude/sounds/notification.mp3 </dev/null >/dev/null 2>&1 &)";
          }
        ];
      }
    ];
    # タスク完了(Stop)後はフラグファイルを立て、次のプロンプト送信
    # (UserPromptSubmit)までアイドル通知(idle_prompt)を鳴らさない。
    Notification = [
      {
        matcher = "idle_prompt";
        hooks = [
          {
            type = "command";
            command = "[ -f /tmp/claude_task_stopped_$PPID ] || (mpv --no-terminal --volume=30 ~/.claude/sounds/notification.mp3 </dev/null >/dev/null 2>&1 &)";
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
            command = "touch /tmp/claude_task_stopped_$PPID; (mpv --no-terminal --volume=30 ~/.claude/sounds/stop.mp3 </dev/null >/dev/null 2>&1 &)";
          }
        ];
      }
    ];
    UserPromptSubmit = [
      {
        matcher = "";
        hooks = [
          {
            type = "command";
            command = "rm -f /tmp/claude_task_stopped_$PPID";
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
          # rtk proxy へコマンドを書き換え、出力を圧縮してトークンを削減する。
          # 禁止コマンドの判定は書き換え前の入力に対して行われるため、
          # pre-bash.sh のガードはこの hook の影響を受けない。
          {
            type = "command";
            command = "rtk hook claude";
          }
        ];
      }
    ];
  };

  scripts = {
    ".claude/scripts/pre-bash.sh" = mkScript (shared + "/scripts/pre-bash.sh");
    ".claude/scripts/statusline.sh" = mkScript ./scripts/statusline.sh;
    ".claude/scripts/git/check.sh" = mkScript (shared + "/scripts/git/check.sh");
    ".claude/scripts/git/block-default-push.sh" = mkScript (shared + "/scripts/git/block-default-push.sh");
    ".claude/scripts/git/block-force-push.sh" = mkScript (shared + "/scripts/git/block-force-push.sh");
    ".claude/scripts/git/block-no-verify.sh" = mkScript (shared + "/scripts/git/block-no-verify.sh");
    ".claude/scripts/git/block-amend-pushed.sh" = mkScript (shared + "/scripts/git/block-amend-pushed.sh");
    ".claude/scripts/git/block-clone.sh" = mkScript (shared + "/scripts/git/block-clone.sh");
    ".claude/scripts/gh/check.sh" = mkScript (shared + "/scripts/gh/check.sh");
    ".claude/scripts/gh/block-repo-clone.sh" = mkScript (shared + "/scripts/gh/block-repo-clone.sh");
    ".claude/scripts/gh/block-pr-body.sh" = mkScript (shared + "/scripts/gh/block-pr-body.sh");
    ".claude/scripts/gh/pr-create.sh" = mkScript ./scripts/pr-create.sh;
  };
}
