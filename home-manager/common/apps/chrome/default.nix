{ pkgs, lib, ... }:
{
  home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [ pkgs.google-chrome ];

  home.activation.copyGoogleChrome = lib.mkIf (!pkgs.stdenv.hostPlatform.isLinux) (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      app_dst="/Applications/Google Chrome.app"
      if [ ! -d "$app_dst" ]; then
        cp -R "${pkgs.google-chrome}/Applications/Google Chrome.app" "$app_dst"
        chmod -R u+w "$app_dst"
      fi
    ''
  );
}
