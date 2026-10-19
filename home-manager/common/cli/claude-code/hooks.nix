{
  pkgs,
  isucon ? false,
}:
let
  # executable = true makes home-manager copy the file to set its mode, so the exec bit lives in git and the file stays a symlink to the store
  mkScript = src: { source = src; };
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
            command = whenAttended "[ -f /tmp/claude_task_stopped_$PPID ] || ${playSound "notification.mp3"}";
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
            command = whenAttended "touch /tmp/claude_task_stopped_$PPID; ${playSound "stop.mp3"}";
          }
          {
            type = "command";
            command = "$HOME/.claude/scripts/herdr-name-tab.sh";
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
          # Hooks are disabled in the summarizer so its Stop does not play the stop sound
          {
            type = "command";
            command = "$HOME/.claude/scripts/herdr-name-tab.sh --model sonnet --no-session-persistence --tools '' --settings '{\"disableAllHooks\":true}'";
          }
        ];
      }
    ];
    PostToolUse = [
      {
        matcher = "^(Write|Edit|NotebookEdit)$";
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
      # A "/" in the name nests the worktree below a direct child of .claude/worktrees
      {
        matcher = "^EnterWorktree$";
        hooks = [
          {
            type = "command";
            command = ''if jq -e '.tool_input.name // "" | contains("/")' >/dev/null; then echo 'Blocked: worktree names must not contain "/".' >&2; exit 2; fi'';
          }
        ];
      }
    ];
  };

  scripts = {
    ".claude/scripts/rtk-hook.sh" = mkScript (shared + "/scripts/rtk-hook.sh");
    ".claude/scripts/ensure-trailing-newline.sh" = mkScript (
      shared + "/scripts/ensure-trailing-newline.sh"
    );
    ".claude/scripts/herdr-name-tab.sh" = mkScript (shared + "/scripts/herdr-name-tab.sh");
    ".claude/scripts/statusline.sh" = mkScript ./scripts/statusline.sh;
  }
  # block-pr-body.sh is the only guard that points agents at this wrapper
  // (if isucon then { } else { ".claude/scripts/gh/pr-body.sh" = mkScript ./scripts/pr-body.sh; })
  // import (shared + "/scripts.nix") {
    inherit pkgs isucon;
    dir = ".claude/scripts";
  };
}
