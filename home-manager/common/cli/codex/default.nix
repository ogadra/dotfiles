{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  codex-unwrapped = inputs.llm-agents.packages.${pkgs.system}.codex;
  codex = pkgs.symlinkJoin {
    name = "codex-wrapped";
    paths = [ codex-unwrapped ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/codex \
        --prefix PATH : ${lib.makeBinPath [
          pkgs.bash
          pkgs.git
          pkgs.jq
          pkgs.mpv
        ]} \
        --add-flags "--profile ogadra" \
        --run 'export GIT_CONFIG_GLOBAL="''${GIT_CONFIG_GLOBAL:-$HOME/.codex/config/.gitconfig}"' \
        --set-default GIT_CONFIG_SYSTEM /dev/null
    '';
  };

  mkScript = src: {
    source = src;
    executable = true;
  };
in
{
  home.packages = [ codex ];

  home.file = {
    ".codex/ogadra.config.toml".source = ./ogadra.config.toml;
    ".codex/AGENTS.md".source = ./AGENTS.md;
    ".codex/config/.gitconfig".source = ../claude-code/.gitconfig;
    ".codex/sounds/notification.mp3".source = ../claude-code/sounds/notification.mp3;
    ".codex/sounds/stop.mp3".source = ../claude-code/sounds/stop.mp3;

    ".codex/scripts/pre-bash.sh" = mkScript ./scripts/pre-bash.sh;
    ".codex/scripts/git/check.sh" = mkScript ../claude-code/scripts/git/check.sh;
    ".codex/scripts/git/block-default-push.sh" = mkScript ../claude-code/scripts/git/block-default-push.sh;
    ".codex/scripts/git/block-no-verify.sh" = mkScript ../claude-code/scripts/git/block-no-verify.sh;
    ".codex/scripts/git/block-clone.sh" = mkScript ../claude-code/scripts/git/block-clone.sh;
    ".codex/scripts/gh/check.sh" = mkScript ../claude-code/scripts/gh/check.sh;
    ".codex/scripts/gh/block-repo-clone.sh" = mkScript ../claude-code/scripts/gh/block-repo-clone.sh;
  };
}
