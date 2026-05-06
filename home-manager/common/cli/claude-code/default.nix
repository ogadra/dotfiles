{
  inputs,
  pkgs,
  ...
}:
let
  claude-code = inputs.claude-code-overlay.packages.${pkgs.system}.default;
  settingsJson = builtins.toJSON {
    permissions = import ./permissions.nix;
    hooks = import ./hooks.nix;
    alwaysThinkingEnabled = false;
    autoUpdates = false;
    defaultModel = "opus";
  };
in
{
  home.packages = [ claude-code ];

  home.file = {
    ".claude/sounds/notification.mp3".source = ./sounds/notification.mp3;
    ".claude/sounds/stop.mp3".source = ./sounds/stop.mp3;
    ".claude/settings.json".text = settingsJson;
  };
}
