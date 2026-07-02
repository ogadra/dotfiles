{ config, lib, pkgs, ... }:
let
  gitleaksConfig = "${config.xdg.configHome}/gitleaks/gitleaks.toml";
  gitleaksRelPath = "github.com/ogadra/dotfiles/data/gitleaks.toml";

  preCommit = pkgs.writeShellScript "pre-commit" ''
    set -e

    if command -v gitleaks >/dev/null 2>&1; then
      gitleaks protect --staged --redact --no-banner
    fi

    git_dir="$(git rev-parse --git-dir)"
    repo_hook="$git_dir/hooks/pre-commit"
    if [ -x "$repo_hook" ]; then
      exec "$repo_hook" "$@"
    fi
  '';
in
{
  home.packages = [ pkgs.gitleaks ];

  home.sessionVariables.GITLEAKS_CONFIG = gitleaksConfig;

  xdg.configFile."git/hooks/pre-commit" = {
    source = preCommit;
    executable = true;
  };

  programs.git.settings.core.hooksPath = "${config.xdg.configHome}/git/hooks";

  home.activation.gitleaksConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ghq_root="$(${pkgs.ghq}/bin/ghq root 2>/dev/null || true)"
    if [ -n "$ghq_root" ] && [ -f "$ghq_root/${gitleaksRelPath}" ]; then
      run mkdir -p "$(dirname "${gitleaksConfig}")"
      run cp -f "$ghq_root/${gitleaksRelPath}" "${gitleaksConfig}"
    fi
  '';
}
