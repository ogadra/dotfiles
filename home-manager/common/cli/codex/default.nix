{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  shared = ../../modules/llm-agent;
  codex-unwrapped = inputs.llm-agents.packages.${pkgs.system}.codex.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./patches/codex-status-line-used-limits.patch
    ];
  });
  codex-wrapper = pkgs.writeShellScriptBin "codex" ''
    set -euo pipefail

    export PATH="${
      lib.makeBinPath [
        pkgs.bash
        pkgs.git
        pkgs.jq
        pkgs.mpv
        inputs.llm-agents.packages.${pkgs.system}.ccusage
      ]
    }:$PATH"
    export GIT_CONFIG_GLOBAL="''${GIT_CONFIG_GLOBAL:-$HOME/.codex/config/.gitconfig}"
    export GIT_CONFIG_SYSTEM="''${GIT_CONFIG_SYSTEM:-/dev/null}"
    export CO_AUTHOR="Codex <199175422+chatgpt-codex-connector[bot]@users.noreply.github.com>"

    case "''${1-}" in
      ""|exec|e|review|resume|archive|unarchive|fork|sandbox)
        exec ${codex-unwrapped}/bin/codex --profile ogadra "$@"
        ;;
      mcp)
        exec ${codex-unwrapped}/bin/codex --profile ogadra "$@"
        ;;
      debug)
        if [ "''${2-}" = "prompt-input" ]; then
          exec ${codex-unwrapped}/bin/codex --profile ogadra "$@"
        fi
        exec ${codex-unwrapped}/bin/codex "$@"
        ;;
      *)
        exec ${codex-unwrapped}/bin/codex "$@"
        ;;
    esac
  '';
  # Codex applies updatedInput only alongside permissionDecision allow, which rtk's hook output leaves out
  rtk-hook = pkgs.writeShellScript "codex-rtk-hook" ''
    ${pkgs.bash}/bin/bash ${shared + "/scripts/rtk-hook.sh"} \
      | ${pkgs.jq}/bin/jq -c 'if .hookSpecificOutput.updatedInput then .hookSpecificOutput.permissionDecision = "allow" else . end'
  '';
  hooksJson = builtins.toJSON {
    hooks.PreToolUse = [
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = "${rtk-hook}";
          }
        ];
      }
    ];
  };
  codex = pkgs.symlinkJoin {
    name = "codex-wrapped";
    paths = [
      codex-wrapper
      codex-unwrapped
    ];
  };
in
{
  home.packages = [ codex ];

  home.file = {
    ".codex/ogadra.config.toml".source = ./ogadra.config.toml;
    ".codex/AGENTS.md".source = shared + "/AGENTS.md";
    ".codex/RTK.md".source = ../rtk/RTK.md;
    ".codex/hooks.json".text = hooksJson;
    ".codex/packages/standalone/current/codex".source = codex + "/bin/codex";
    ".codex/rules/default.rules" = {
      source = ./default.rules;
      force = true;
    };
    ".codex/config/.gitconfig".source = shared + "/.gitconfig";
  };

  home.activation.enableCodexRemoteControl = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${codex}/bin/codex app-server daemon enable-remote-control >/dev/null
  '';
}
