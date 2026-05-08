{
  inputs,
  pkgs,
  ...
}:
let
  claude-code-unwrapped = inputs.llm-agents.packages.${pkgs.system}.claude-code;
  claude-code = pkgs.symlinkJoin {
    name = "claude-code-wrapped";
    paths = [ claude-code-unwrapped ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/claude \
        --run 'export GIT_CONFIG_GLOBAL="''${GIT_CONFIG_GLOBAL:-$HOME/.claude/config/.gitconfig}"' \
        --set-default GIT_CONFIG_SYSTEM /dev/null
    '';
  };
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
    ".claude/config/.gitconfig".source = ./.gitconfig;
    ".claude/scripts/block-push-to-default-branch.sh" = {
      source = ./scripts/block-push-to-default-branch.sh;
      executable = true;
    };
  };
}
