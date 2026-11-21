{
  config,
  lib,
  pkgs,
  ...
}:
let
  gitleaksConfig = "${config.xdg.configHome}/gitleaks/gitleaks.toml";
  gitleaksRelPath = "github.com/ogadra/dotfiles/data/gitleaks.toml";
in
{
  home.packages = [ pkgs.gitleaks ];

  home.sessionVariables.GITLEAKS_CONFIG = gitleaksConfig;

  home.activation.gitleaksConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ghq_root="$(${pkgs.ghq}/bin/ghq root 2>/dev/null || true)"
    if [ -n "$ghq_root" ] && [ -f "$ghq_root/${gitleaksRelPath}" ]; then
      run mkdir -p "$(dirname "${gitleaksConfig}")"
      run cp -f "$ghq_root/${gitleaksRelPath}" "${gitleaksConfig}"
    fi
  '';
}
