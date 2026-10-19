{
  pkgs,
  isucon ? false,
}:
let
  # executable = true makes home-manager copy the file to set its mode, so the exec bit lives in git and the file stays a symlink to the store
  mkScript = src: { source = src; };
  shared = ../../modules/llm-agent;

  # The tab-naming summarizer runs devin with HERDR_TAB_NAMING set and must stay silent
  playSound =
    sound:
    ''[ -n "$HERDR_TAB_NAMING" ] || $HOME/.config/devin/scripts/play-sound.sh $HOME/.config/devin/sounds/${sound}'';
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
    UserPromptSubmit = [
      {
        matcher = "";
        hooks = [
          {
            type = "command";
            command = "$HOME/.config/devin/scripts/herdr-name-tab.sh --model swe-2";
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
          {
            type = "command";
            command = "$HOME/.config/devin/scripts/herdr-name-tab.sh";
          }
        ];
      }
    ];
  };

  scripts = {
    ".config/devin/scripts/rtk-hook.sh" = mkScript (shared + "/scripts/rtk-hook.sh");
    ".config/devin/scripts/herdr-name-tab.sh" = mkScript (shared + "/scripts/herdr-name-tab.sh");
    ".config/devin/scripts/play-sound.sh" = mkScript (shared + "/scripts/play-sound.sh");
    ".config/devin/scripts/ensure-trailing-newline.sh" = mkScript (
      shared + "/scripts/ensure-trailing-newline.sh"
    );
  }
  // import (shared + "/scripts.nix") {
    inherit pkgs isucon;
    dir = ".config/devin/scripts";
  };
}
