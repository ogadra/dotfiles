{ lib, ... }:
let
  version = "1.9.1";
  dmgUrl = "https://shottr.cc/dl/Shottr-${version}.dmg";
  dmgSha256 = "0bfd797dbcfec52a5e122b50062ad6b954847fe3b53d676c05ac4361f50ce5b3";
in
{
  home.activation.installShottr = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/Shottr.app" ]; then
      _dmg=$(mktemp /tmp/shottr-XXXXXX.dmg)
      /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
      echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { rm -f "$_dmg"; exit 1; }
      _mnt=$(/usr/bin/mktemp -d /tmp/shottr-mnt-XXXXXX)
      /usr/bin/hdiutil attach "$_dmg" -mountpoint "$_mnt" -nobrowse -quiet
      /bin/cp -R "$_mnt/Shottr.app" /Applications/
      /usr/bin/xattr -dr com.apple.quarantine /Applications/Shottr.app
      /usr/bin/hdiutil detach "$_mnt" -quiet
      rm -f "$_dmg"
    fi
  '';
}
