{
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
      # A subagent runs hidden inside this session, while a herdr tab keeps the work visible and steerable from its own pane
      {
        matcher = "^Agent$";
        hooks = [
          {
            type = "command";
            command = whenAttended ''[ "''${HERDR_ENV:-}" != 1 ] || { echo 'Blocked: subagents are disabled in herdr sessions. Run the work in a herdr tab with `herdr tab create`, `herdr agent start` and `herdr agent prompt`.' >&2; exit 2; }'';
          }
        ];
      }
    ];
  };

  scripts = {
    ".claude/scripts/pre-bash.sh" = mkScript (shared + "/scripts/pre-bash.sh");
    ".claude/scripts/normalize.sh" = mkScript (shared + "/scripts/normalize.sh");
    ".claude/scripts/rtk-hook.sh" = mkScript (shared + "/scripts/rtk-hook.sh");
    ".claude/scripts/ensure-trailing-newline.sh" = mkScript (
      shared + "/scripts/ensure-trailing-newline.sh"
    );
    ".claude/scripts/herdr-name-tab.sh" = mkScript (shared + "/scripts/herdr-name-tab.sh");
    ".claude/scripts/statusline.sh" = mkScript ./scripts/statusline.sh;
    ".claude/scripts/git/check.sh" = mkScript (shared + "/scripts/git/check.sh");
    ".claude/scripts/git/block-default-commit.sh" = mkScript (
      shared + "/scripts/git/block-default-commit.sh"
    );
    ".claude/scripts/git/block-default-push.sh" = mkScript (
      shared + "/scripts/git/block-default-push.sh"
    );
    ".claude/scripts/git/block-force-push.sh" = mkScript (shared + "/scripts/git/block-force-push.sh");
    ".claude/scripts/git/block-rewrite-pushed.sh" = mkScript (
      shared + "/scripts/git/block-rewrite-pushed.sh"
    );
    ".claude/scripts/git/block-clone.sh" = mkScript (shared + "/scripts/git/block-clone.sh");
    ".claude/scripts/git/block-worktree-outside.sh" = mkScript (
      shared + "/scripts/git/block-worktree-outside.sh"
    );
    ".claude/scripts/gh/check.sh" = mkScript (shared + "/scripts/gh/check.sh");
    ".claude/scripts/gh/block-repo-clone.sh" = mkScript (shared + "/scripts/gh/block-repo-clone.sh");
    ".claude/scripts/gh/block-pr-close.sh" = mkScript (shared + "/scripts/gh/block-pr-close.sh");
    ".claude/scripts/gh/pr-body.sh" = mkScript ./scripts/pr-body.sh;
  }
  // (
    if isucon then
      { }
    else
      {
        ".claude/scripts/block-sudo.sh" = mkScript (shared + "/scripts/block-sudo.sh");
        ".claude/scripts/git/block-no-verify.sh" = mkScript (shared + "/scripts/git/block-no-verify.sh");
        ".claude/scripts/git/block-merge-non-base.sh" = mkScript (
          shared + "/scripts/git/block-merge-non-base.sh"
        );
        ".claude/scripts/git/block-cherry-pick-stacked.sh" = mkScript (
          shared + "/scripts/git/block-cherry-pick-stacked.sh"
        );
        ".claude/scripts/git/block-commit-all.sh" = mkScript (shared + "/scripts/git/block-commit-all.sh");
        ".claude/scripts/git/block-bulk-add.sh" = mkScript (shared + "/scripts/git/block-bulk-add.sh");
        ".claude/scripts/gh/block-pr-body.sh" = mkScript (shared + "/scripts/gh/block-pr-body.sh");
      }
  );
}
