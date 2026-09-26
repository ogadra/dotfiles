let
  mkScript = src: {
    source = src;
    executable = true;
  };
  shared = ../../modules/llm-agent;

  playSound = sound: "$HOME/.config/devin/scripts/play-sound.sh $HOME/.config/devin/sounds/${sound}";
in
{
  # Devin reads Claude Code's hook schema, so event names and the command type carry over unchanged
  hooks = {
    PreToolUse = [
      {
        # Devin's shell tool is lowercase "exec", so Claude's "Bash" matcher never fires here
        matcher = "^exec$";
        hooks = [
          {
            type = "command";
            command = "$HOME/.config/devin/scripts/pre-bash.sh";
          }
          {
            type = "command";
            command = "$HOME/.config/devin/scripts/rtk-hook.sh";
          }
        ];
      }
    ];
    PostToolUse = [
      {
        matcher = "^(edit|write|notebook_edit)$";
        hooks = [
          {
            type = "command";
            command = "$HOME/.config/devin/scripts/ensure-trailing-newline.sh";
          }
        ];
      }
    ];
    # Devin has no Notification event, so the permission prompt carries the notification sound
    PermissionRequest = [
      {
        matcher = "";
        hooks = [
          {
            type = "command";
            command = playSound "notification.mp3";
          }
        ];
      }
    ];
    # Devin sessions are always attended, so no CLAUDE_CODE_SESSION_ATTENDED guard is needed
    Stop = [
      {
        matcher = "";
        hooks = [
          {
            type = "command";
            command = playSound "stop.mp3";
          }
        ];
      }
    ];
  };

  scripts = {
    ".config/devin/scripts/pre-bash.sh" = mkScript (shared + "/scripts/pre-bash.sh");
    ".config/devin/scripts/normalize.sh" = mkScript (shared + "/scripts/normalize.sh");
    ".config/devin/scripts/rtk-hook.sh" = mkScript (shared + "/scripts/rtk-hook.sh");
    ".config/devin/scripts/play-sound.sh" = mkScript (shared + "/scripts/play-sound.sh");
    ".config/devin/scripts/ensure-trailing-newline.sh" = mkScript (
      shared + "/scripts/ensure-trailing-newline.sh"
    );
    ".config/devin/scripts/git/check.sh" = mkScript (shared + "/scripts/git/check.sh");
    ".config/devin/scripts/git/block-default-push.sh" = mkScript (
      shared + "/scripts/git/block-default-push.sh"
    );
    ".config/devin/scripts/git/block-force-push.sh" = mkScript (
      shared + "/scripts/git/block-force-push.sh"
    );
    ".config/devin/scripts/git/block-no-verify.sh" = mkScript (
      shared + "/scripts/git/block-no-verify.sh"
    );
    ".config/devin/scripts/git/block-amend-pushed.sh" = mkScript (
      shared + "/scripts/git/block-amend-pushed.sh"
    );
    ".config/devin/scripts/git/block-clone.sh" = mkScript (shared + "/scripts/git/block-clone.sh");
    ".config/devin/scripts/gh/check.sh" = mkScript (shared + "/scripts/gh/check.sh");
    ".config/devin/scripts/gh/block-repo-clone.sh" = mkScript (
      shared + "/scripts/gh/block-repo-clone.sh"
    );
    ".config/devin/scripts/gh/block-pr-body.sh" = mkScript (shared + "/scripts/gh/block-pr-body.sh");
    ".config/devin/scripts/gh/block-pr-close.sh" = mkScript (shared + "/scripts/gh/block-pr-close.sh");
  };
}
