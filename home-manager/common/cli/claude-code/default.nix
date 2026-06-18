{
  inputs,
  pkgs,
  ...
}:
let
  shared = ../../modules/llm-agent;
  system = pkgs.stdenv.hostPlatform.system;
  claude-code-unwrapped = inputs.llm-agents.packages.${system}.claude-code;
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
  hooksConfig = import ./hooks.nix;

  settingsJson = builtins.toJSON (import ./settings.nix { inherit hooksConfig; });
in
{
  home.packages = [ claude-code ];

  home.file = {
    ".claude/sounds/notification.mp3".source = ../../sounds/notification.mp3;
    ".claude/sounds/stop.mp3".source = ../../sounds/stop.mp3;
    ".claude/settings.json".text = settingsJson;
    ".claude/CLAUDE.md".source = ./CLAUDE.md;
    ".claude/config/.gitconfig".source = shared + "/.gitconfig";
    ".claude/skills/cascade-merge/SKILL.md".source = ./skills/cascade-merge/SKILL.md;
    ".claude/skills/stop-ai-slop-jp".source = inputs.stop-ai-slop-jp;
  } // hooksConfig.scripts;
}
