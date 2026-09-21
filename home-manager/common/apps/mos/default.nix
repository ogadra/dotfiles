{ lib, ... }:
let
  # Mos ships a Sparkle zip whose URL carries a build timestamp, so version alone cannot build it
  zipUrl = "https://github.com/Caldis/Mos/releases/download/4.2.1/Mos.Versions.4.2.1-20260531.1.zip";
  zipSha256 = "2ea69e96f092e44dada93a55bda1cddab3329c527bbd5f06e00dfb78e953960a";
in
{
  targets.darwin.defaults."com.caldis.Mos" = {
    smooth = true;
    reverse = false; # true is the natural scroll direction
    duration = 3.9;
    speed = 3;
    step = 35;
    precision = 1;
    dash = 0; # Accelerated scrolling
    toggle = 0; # Key that suspends smooth scrolling
    block = 0;
    allowlist = false;
    hideStatusItem = false;
    optionsExist = "optionsExist"; # Flag Mos reads as having been configured
  };

  home.activation.installMos = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/Mos.app" ]; then
      _zip=$(mktemp /tmp/mos-XXXXXX.zip)
      /usr/bin/curl -L -o "$_zip" "${zipUrl}"
      echo "${zipSha256}  $_zip" | /usr/bin/shasum -a 256 -c - || { rm -f "$_zip"; exit 1; }
      _dir=$(/usr/bin/mktemp -d /tmp/mos-dir-XXXXXX)
      /usr/bin/unzip -q "$_zip" -d "$_dir"
      /bin/cp -R "$_dir/Mos.app" /Applications/
      /usr/bin/xattr -dr com.apple.quarantine /Applications/Mos.app
      rm -rf "$_zip" "$_dir"
    fi
  '';
}
