{ lib, ... }:
let
  version = "2.8.0";
  zipUrl = "https://github.com/p0deje/Maccy/releases/download/${version}/Maccy.app.zip";
  zipSha256 = "e684e1ce0c60d7cffd3a2b182dc37bd7e88c29967a64a431a2c71be65b1d27e0";
in
{
  targets.darwin.defaults."org.p0deje.Maccy" = {
    # Opt+Cmd+V; carbonKeyCode 9 is V, carbonModifiers 2304 is cmdKey (256) + optionKey (2048)
    KeyboardShortcuts_popup = builtins.toJSON {
      carbonKeyCode = 9;
      carbonModifiers = 2304;
    };
  };

  home.activation.installMaccy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/Maccy.app" ]; then
      _zip=$(mktemp /tmp/maccy-XXXXXX.zip)
      /usr/bin/curl -L -o "$_zip" "${zipUrl}"
      echo "${zipSha256}  $_zip" | /usr/bin/shasum -a 256 -c - || { rm -f "$_zip"; exit 1; }
      _dir=$(/usr/bin/mktemp -d /tmp/maccy-dir-XXXXXX)
      /usr/bin/unzip -q "$_zip" -d "$_dir"
      /bin/cp -R "$_dir/Maccy.app" /Applications/
      /usr/bin/xattr -dr com.apple.quarantine /Applications/Maccy.app
      rm -rf "$_zip" "$_dir"
    fi
  '';
}
