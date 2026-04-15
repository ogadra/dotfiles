{
  pkgs,
  lib,
  ...
}:
{
  home.activation.copy1Password = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    app_dst="/Applications/1Password.app"
    if [ ! -d "$app_dst" ]; then
      cp -R "${pkgs._1password-gui}/Applications/1Password.app" "$app_dst"
      chmod -R u+w "$app_dst"
    fi
    rm -rf "$HOME/Applications/Home Manager Apps/1Password.app"
  '';
}
