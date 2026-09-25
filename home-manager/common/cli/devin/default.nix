{
  pkgs,
  lib,
  ...
}:
let
  shared = ../../modules/llm-agent;

  mkScript = src: {
    source = src;
    executable = true;
  };

  playSound = sound: "$HOME/.config/devin/scripts/play-sound.sh $HOME/.config/devin/sounds/${sound}";

  # Claude Code hook format with Devin's lowercase tool names as matchers.
  hooks = {
    # Guards then output compression, same order and scripts as the Claude Code hooks
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
        # Devin's file-writing tools
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

  # Exec() rules only match the leading words of a command, so commands hidden in pipes or chains are left to the pre-bash hook
  permissions = {
    allow = [
      "Exec(git push origin)"
      "Exec(git push -u origin)"
    ];
    deny = [
      "Exec(sudo)"
      "Exec(xargs rm)"
      "Exec(git commit -a)"
      "Exec(git add .)"
      "Exec(git add -u)"
      "Exec(git add -A)"
    ];
  };

  mergedConfig = pkgs.writeText "devin-config-fragment.json" (builtins.toJSON { inherit hooks permissions; });
in
{
  home.packages = [ pkgs.devin-cli ];

  home.file = {
    ".config/devin/sounds/notification.mp3".source = ../../sounds/notification.mp3;
    ".config/devin/sounds/stop.mp3".source = ../../sounds/stop.mp3;
    ".config/devin/scripts/pre-bash.sh" = mkScript (shared + "/scripts/pre-bash.sh");
    ".config/devin/scripts/normalize.sh" = mkScript (shared + "/scripts/normalize.sh");
    ".config/devin/scripts/rtk-hook.sh" = mkScript (shared + "/scripts/rtk-hook.sh");
    ".config/devin/scripts/play-sound.sh" = mkScript (shared + "/scripts/play-sound.sh");
    ".config/devin/scripts/ensure-trailing-newline.sh" = mkScript ./scripts/ensure-trailing-newline.sh;
    ".config/devin/scripts/git/check.sh" = mkScript (shared + "/scripts/git/check.sh");
    ".config/devin/scripts/git/block-default-push.sh" = mkScript (shared + "/scripts/git/block-default-push.sh");
    ".config/devin/scripts/git/block-force-push.sh" = mkScript (shared + "/scripts/git/block-force-push.sh");
    ".config/devin/scripts/git/block-no-verify.sh" = mkScript (shared + "/scripts/git/block-no-verify.sh");
    ".config/devin/scripts/git/block-amend-pushed.sh" = mkScript (shared + "/scripts/git/block-amend-pushed.sh");
    ".config/devin/scripts/git/block-clone.sh" = mkScript (shared + "/scripts/git/block-clone.sh");
    ".config/devin/scripts/gh/check.sh" = mkScript (shared + "/scripts/gh/check.sh");
    ".config/devin/scripts/gh/block-repo-clone.sh" = mkScript (shared + "/scripts/gh/block-repo-clone.sh");
    ".config/devin/scripts/gh/block-pr-body.sh" = mkScript (shared + "/scripts/gh/block-pr-body.sh");
  };

  # devin itself rewrites config.json (model, org), so merge the managed keys instead of replacing the file
  home.activation.mergeDevinConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config="$HOME/.config/devin/config.json"
    mkdir -p "$(dirname "$config")"
    [ -f "$config" ] || printf '{}\n' > "$config"
    # The hooks key is owned here wholesale; allow and deny are unioned so hand-added entries survive
    tmp=$(mktemp)
    if ${pkgs.jq}/bin/jq -e . "$config" > /dev/null 2>&1; then
      ${pkgs.jq}/bin/jq --slurpfile fragment ${mergedConfig} '
        . + { hooks: $fragment[0].hooks }
        | .permissions.allow = (((.permissions.allow // []) + $fragment[0].permissions.allow) | unique)
        | .permissions.deny = (((.permissions.deny // []) + $fragment[0].permissions.deny) | unique)
      ' "$config" > "$tmp" && cat "$tmp" > "$config"
    fi
    rm -f "$tmp"
  '';
}
