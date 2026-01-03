{ pkgs, ... }:
let
  # Build wl-clipboard from master for ext-data-control-v1 support (KDE Plasma 6.4+)
  wl-clipboard-master = pkgs.wl-clipboard.overrideAttrs (old: {
    version = "unstable-2025-04-12";
    src = pkgs.fetchFromGitHub {
      owner = "bugaevc";
      repo = "wl-clipboard";
      rev = "091d6028b5c9db75ad36f9fceb0db3ee718045fa";
      sha256 = "sha256-7cUgIc9TxQLWYKBRTUxr0jV+yrOjPCFRgpSahlOUbLU=";
    };
  });
in
{
  home.packages = [ wl-clipboard-master ];
}
