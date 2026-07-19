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
    ".claude/skills/absolute-rules/SKILL.md".source = ./skills/absolute-rules/SKILL.md;
    ".claude/skills/cascade-merge/SKILL.md".source = ./skills/cascade-merge/SKILL.md;
    ".claude/skills/pr-review/SKILL.md".source = ./skills/pr-review/SKILL.md;
    ".claude/skills/pr-review/policies/absolute-rules.md".source = ./skills/pr-review/policies/absolute-rules.md;
    ".claude/skills/pr-review/policies/stop-slop.md".source = ./skills/pr-review/policies/stop-slop.md;
    ".claude/skills/pr-review/policies/security.md".source = ./skills/pr-review/policies/security.md;
    ".claude/skills/pr-review/policies/architecture.md".source = ./skills/pr-review/policies/architecture.md;
    ".claude/skills/pr-review/policies/code-quality.md".source = ./skills/pr-review/policies/code-quality.md;
    ".claude/skills/pr-review/policies/testing.md".source = ./skills/pr-review/policies/testing.md;
    ".claude/skills/pr-review/policies/ai-antipattern.md".source = ./skills/pr-review/policies/ai-antipattern.md;
    ".claude/skills/stop-ai-slop-jp".source = inputs.stop-ai-slop-jp;
    ".claude/skills/stop-slop".source = inputs.stop-slop;
  } // hooksConfig.scripts;
}
