{
  inputs,
  pkgs,
  ...
}:
let
  claude-code = inputs.llm-agents.packages.${pkgs.system}.claude-code;
  settingsJson = builtins.toJSON {
    permissions = import ./permissions.nix;
    hooks = import ./hooks.nix;
    alwaysThinkingEnabled = false;
    autoUpdates = false;
    model = "opus";
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
