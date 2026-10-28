{
  pkgs,
  lib,
  isucon ? false,
  ...
}:
let
  shared = ../../modules/llm-agent;

  devin-cli = pkgs.symlinkJoin {
    name = "devin-cli-wrapped";
    paths = [ pkgs.devin-cli ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/devin \
        --run 'export GIT_CONFIG_GLOBAL="''${GIT_CONFIG_GLOBAL:-$HOME/.config/devin/config/.gitconfig}"' \
        --set-default GIT_CONFIG_SYSTEM /dev/null \
        --set-default DEVIN_PERMISSION_MODE ${if isucon then "dangerous" else "smart"} \
        --set CO_AUTHOR "Devin <158243242+devin-ai-integration[bot]@users.noreply.github.com>"
    '';
  };

  hooksConfig = import ./hooks.nix { inherit isucon; };
  skills = import (shared + "/skills.nix") { inherit lib isucon; };

  mergedConfig = pkgs.writeText "devin-config-fragment.json" (
    builtins.toJSON {
      hooks = hooksConfig.hooks;
      permissions = import ./permissions.nix { inherit isucon; };
      skip_workspace_trust = isucon;
      deny_replace = isucon;
      # Reading ~/.claude/CLAUDE.md would add Claude Code's question rules beside Devin's, and the switch also covers skills, so those are installed below instead
      read_config_from.claude = false;
    }
  );
in
{
  home.packages = [ devin-cli ];

  home.file = {
    ".config/devin/config/.gitconfig".source =
      shared + (if isucon then "/isucon.gitconfig" else "/.gitconfig");
    ".config/devin/sounds/notification.mp3".source = ../../sounds/notification.mp3;
    ".config/devin/sounds/stop.mp3".source = ../../sounds/stop.mp3;
  }
  // lib.optionalAttrs (!isucon) {
    ".config/devin/AGENTS.md".source = import (shared + "/agents-md.nix") {
      inherit pkgs;
      questions = ./questions.md;
    };
    ".config/devin/RTK.md".source = ../rtk/RTK.md;
  }
  // lib.mapAttrs' (
    path: source: lib.nameValuePair ".config/devin/skills/${path}" { inherit source; }
  ) skills
  // hooksConfig.scripts;

  # devin itself rewrites config.json (model, org), so merge the managed keys instead of replacing the file
  home.activation.mergeDevinConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config="$HOME/.config/devin/config.json"
    mkdir -p "$(dirname "$config")"
    [ -f "$config" ] || printf '{}\n' > "$config"
    tmp=$(mktemp)
    # The hooks key is owned here wholesale; allow and deny are unioned so hand-added entries survive
    if ${pkgs.jq}/bin/jq -e . "$config" > /dev/null 2>&1; then
      ${pkgs.jq}/bin/jq --slurpfile fragment ${mergedConfig} '
        . + { hooks: $fragment[0].hooks }
        | .permissions.allow = (((.permissions.allow // []) + $fragment[0].permissions.allow) | unique)
        | .permissions.deny = (if $fragment[0].deny_replace then $fragment[0].permissions.deny else (((.permissions.deny // []) + $fragment[0].permissions.deny) | unique) end)
        | .skip_workspace_trust = $fragment[0].skip_workspace_trust
        | .read_config_from.claude = $fragment[0].read_config_from.claude
      ' "$config" > "$tmp" && cat "$tmp" > "$config"
    fi
    rm -f "$tmp"
  '';
}
