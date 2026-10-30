{
  inputs,
  lib,
  pkgs,
  isucon ? false,
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
        --set-default GIT_CONFIG_SYSTEM /dev/null \
        --set-default NODE_EXTRA_CA_CERTS /etc/ssl/certs/ca-certificates.crt \
        --set CO_AUTHOR "Claude <noreply@anthropic.com>"
    '';
  };
  hooksConfig = import ./hooks.nix { inherit isucon; };

  settingsJson = builtins.toJSON (import ./settings.nix { inherit hooksConfig isucon; });
  skills = import (shared + "/skills.nix") { inherit lib isucon; };
in
{
  home.packages = [ claude-code ];

  home.file = {
    ".claude/sounds/notification.mp3".source = ../../sounds/notification.mp3;
    ".claude/sounds/stop.mp3".source = ../../sounds/stop.mp3;
    ".claude/settings.json".text = settingsJson;
    ".claude/themes/nerv.json".source = ./themes/nerv.json;
    ".claude/config/.gitconfig".source =
      shared + (if isucon then "/isucon.gitconfig" else "/.gitconfig");
    ".claude/CLAUDE.md".source = import (shared + "/agents-md.nix") {
      inherit pkgs isucon;
      questions = ./questions.md;
    };
  }
  // lib.mapAttrs' (
    path: source: lib.nameValuePair ".claude/skills/${path}" { inherit source; }
  ) skills
  // hooksConfig.scripts;

  # Claude has no setting to disable the workspace trust dialog; accepted trust propagates to subdirectories, so seed it for the home and ghq roots.
  home.activation = lib.mkIf isucon {
    acceptClaudeWorkspaceTrust = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      config="$HOME/.claude.json"
      [ -f "$config" ] || printf '{}\n' > "$config"
      tmp=$(mktemp)
      ${pkgs.jq}/bin/jq --arg home "$HOME" '
        .projects[$home].hasTrustDialogAccepted = true
        | .projects["\($home)/codes"].hasTrustDialogAccepted = true
      ' "$config" > "$tmp" && cat "$tmp" > "$config"
      rm -f "$tmp"
    '';
  };
}
