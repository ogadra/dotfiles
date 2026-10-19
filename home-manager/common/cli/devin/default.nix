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

  hooksConfig = import ./hooks.nix { inherit pkgs isucon; };

  mergedConfig = pkgs.writeText "devin-config-fragment.json" (
    builtins.toJSON {
      hooks = hooksConfig.hooks;
      permissions = import ./permissions.nix { inherit isucon; };
      skip_workspace_trust = isucon;
      deny_replace = isucon;
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
      ' "$config" > "$tmp" && cat "$tmp" > "$config"
    fi
    rm -f "$tmp"
  '';
}
