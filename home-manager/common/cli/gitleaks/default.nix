{ config, lib, pkgs, ... }:
let
  gitleaksConfig = "${config.xdg.configHome}/gitleaks/gitleaks.toml";
  gitleaksRelPath = "github.com/ogadra/dotfiles/data/gitleaks.toml";

  hooksDir = "${config.xdg.configHome}/git/hooks";
  lefthookHook = "${hooksDir}/pre-commit.lefthook";

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

    top="$(git rev-parse --show-toplevel)"
    for base in lefthook .lefthook .config/lefthook; do
      for ext in yml yaml toml json; do
        if [ -f "$top/$base.$ext" ]; then
          if [ -x "${lefthookHook}" ]; then
            exec "${lefthookHook}" "$@"
          elif command -v lefthook >/dev/null 2>&1; then
            exec lefthook run pre-commit "$@"
          fi
        fi
      done
    done
  '';
in
{
  home.packages = [ pkgs.gitleaks ];

  home.sessionVariables.GITLEAKS_CONFIG = gitleaksConfig;

  xdg.configFile."git/hooks/pre-commit" = {
    source = preCommit;
    executable = true;
  };

  programs.git.settings.core.hooksPath = hooksDir;

  home.activation.captureLefthookHook = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    hook="${hooksDir}/pre-commit"
    if [ -f "$hook" ] && [ ! -L "$hook" ] && grep -q lefthook "$hook"; then
      run mv "$hook" "${lefthookHook}"
    fi
  '';

  home.activation.gitleaksConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ghq_root="$(${pkgs.ghq}/bin/ghq root 2>/dev/null || true)"
    if [ -n "$ghq_root" ] && [ -f "$ghq_root/${gitleaksRelPath}" ]; then
      run mkdir -p "$(dirname "${gitleaksConfig}")"
      run cp -f "$ghq_root/${gitleaksRelPath}" "${gitleaksConfig}"
    fi
  '';
}
