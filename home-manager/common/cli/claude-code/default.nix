{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  claude-code = inputs.claude-code-overlay.packages.${pkgs.system}.default;
  settingsJson = builtins.toJSON {
    permissions = import ./permissions.nix;
    hooks = import ./hooks.nix;
    alwaysThinkingEnabled = false;
  };
in
{
  home.packages = [ claude-code ];

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.file = {
    ".claude/sounds/notification.mp3".source = ./sounds/notification.mp3;
    ".claude/sounds/stop.mp3".source = ./sounds/stop.mp3;
    ".claude/settings.json".text = settingsJson;
  };

  # Create symlink in ~/.local/bin for "command not found" workaround on Linux
  home.file.".local/bin/claude" = lib.mkIf pkgs.stdenv.isLinux {
    source = "${claude-code}/bin/claude";
  };
}
