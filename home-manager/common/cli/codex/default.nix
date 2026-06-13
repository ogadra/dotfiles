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

    export PATH="${lib.makeBinPath [
      pkgs.bash
      pkgs.git
      pkgs.jq
      pkgs.mpv
    ]}:$PATH"
    export GIT_CONFIG_GLOBAL="''${GIT_CONFIG_GLOBAL:-$HOME/.codex/config/.gitconfig}"
    export GIT_CONFIG_SYSTEM="''${GIT_CONFIG_SYSTEM:-/dev/null}"

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
    ".codex/AGENTS.md".source = ./AGENTS.md;
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
