let
  mkScript = src: {
    source = src;
    executable = true;
  };
  shared = ../../modules/llm-agent;

  playSound =
    sound: "(mpv --no-terminal --volume=30 ~/.claude/sounds/${sound} </dev/null >/dev/null 2>&1 &)";

  whenAttended = command: ''if [ "$CLAUDE_CODE_SESSION_ATTENDED" = "1" ]; then ${command}; fi'';
in
{
  hooks = {
    PermissionRequest = [
      {
        matcher = "";
        hooks = [
          {
            type = "command";
            command = whenAttended (playSound "notification.mp3");
          }
        ];
      }
    ];
    # Stop drops a flag file that mutes the idle_prompt sound until the next UserPromptSubmit
    Notification = [
      {
        matcher = "idle_prompt";
        hooks = [
          {
            type = "command";
            command = whenAttended ''[ -f /tmp/claude_task_stopped_$PPID ] || ${
              playSound "notification.mp3"
            }'';
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
            command = whenAttended ''touch /tmp/claude_task_stopped_$PPID; ${
              playSound "stop.mp3"
            }'';
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
            command = "$HOME/.claude/scripts/ensure-trailing-newline.sh";
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
          # Rewriting the command through the rtk proxy compresses its output; pre-bash.sh still judges the original input, so its guards survive this hook
          {
            type = "command";
            command = "$HOME/.claude/scripts/rtk-hook.sh";
          }
        ];
      }
    ];
  };

  scripts = {
    ".claude/scripts/pre-bash.sh" = mkScript (shared + "/scripts/pre-bash.sh");
    ".claude/scripts/normalize.sh" = mkScript (shared + "/scripts/normalize.sh");
    ".claude/scripts/rtk-hook.sh" = mkScript (shared + "/scripts/rtk-hook.sh");
    ".claude/scripts/ensure-trailing-newline.sh" = mkScript (shared + "/scripts/ensure-trailing-newline.sh");
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
    ".claude/scripts/gh/pr-body.sh" = mkScript ./scripts/pr-body.sh;
  };
}
