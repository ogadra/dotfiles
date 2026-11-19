{
  pkgs,
  lib,
  isucon ? false,
  ...
}:
let
  shared = ../../modules/llm-agent;

  # static.devin.ai deletes superseded tarballs, so nixpkgs' pinned 3000.12.57 returns 403; values come from https://static.devin.ai/cli/current/manifest.json
  devinVersion = "3000.14.30821";
  devinSources = {
    x86_64-linux = {
      target = "x86_64-unknown-linux";
      sha256 = "4dc43e3e4388bace60fe2aa8010cbb399402e724892d7175845b1cdef00e7ddb";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux";
      sha256 = "3deb8af6b026060e975ed371936e139818020e5dc5abbcba07cde039f473a5a5";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      sha256 = "46ef1a75d8bd851665179e136b7e39ad597d3d7913b95d67fd2b88e9c8af0061";
    };
  };
  devinSource = devinSources.${pkgs.stdenv.hostPlatform.system};
  devin-cli-unwrapped = pkgs.devin-cli.overrideAttrs {
    version = devinVersion;
    src = pkgs.fetchurl {
      url = "https://static.devin.ai/cli/${devinVersion}/devin-${devinVersion}-${devinSource.target}.tar.gz";
      inherit (devinSource) sha256;
    };
  };

  devin-cli = pkgs.symlinkJoin {
    name = "devin-cli-wrapped";
    paths = [ devin-cli-unwrapped ];
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

  mergedConfig = pkgs.writeText "devin-config-fragment.json" (
    builtins.toJSON {
      hooks = hooksConfig.hooks;
      permissions = import ./permissions.nix { inherit isucon; };
      skip_workspace_trust = isucon;
      deny_replace = isucon;
      # Reading ~/.claude would add Claude Code's question rules beside Devin's, so the rules come from ~/.config/devin and the skills from ~/.agents/skills
      read_config_from.claude = false;
    }
  );
in
{
  imports = [ (shared + "/agents-skills.nix") ];

  home.packages = [ devin-cli ];

  home.file = {
    ".config/devin/config/.gitconfig".source =
      shared + (if isucon then "/isucon.gitconfig" else "/.gitconfig");
    ".config/devin/AGENTS.md".source = import (shared + "/agents-md.nix") {
      inherit pkgs isucon;
      questions = ./questions.md;
    };
  }
  // lib.optionalAttrs (!isucon) {
    ".config/devin/RTK.md".source = ../rtk/RTK.md;
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
        | .read_config_from.claude = $fragment[0].read_config_from.claude
      ' "$config" > "$tmp" && cat "$tmp" > "$config"
    fi
    rm -f "$tmp"
  '';
}
