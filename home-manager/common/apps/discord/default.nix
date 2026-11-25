{ pkgs, lib, ... }:
{
  home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [ pkgs.discord ];

  home.activation.copyDiscord = lib.mkIf (!pkgs.stdenv.hostPlatform.isLinux) (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      app_dst="/Applications/Discord.app"
      if [ ! -d "$app_dst" ]; then
        cp -R "${pkgs.discord}/Applications/Discord.app" "$app_dst"
        chmod -R u+w "$app_dst"
      fi
    ''
  );
}
