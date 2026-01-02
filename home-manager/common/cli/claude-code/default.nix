{
  inputs,
  ...
}:
{
  imports = [
    inputs.claude-code-overlay.homeManagerModules.default
  ];

  programs.claude-code = {
    enable = true;
    settings = {
      permissions = import ./permissions.nix;
      hooks = import ./hooks.nix;
      alwaysThinkingEnabled = false;
    };
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.file = {
    ".claude/sounds/notification.mp3".source = ./sounds/notification.mp3;
    ".claude/sounds/stop.mp3".source = ./sounds/stop.mp3;
  };
}
