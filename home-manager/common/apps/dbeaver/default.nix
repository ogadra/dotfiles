{ lib, ... }:
let
  version = "26.1.0";
  dmgUrl = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-macos-aarch64.dmg";
  dmgSha256 = "b3e350e61a7736242927f6f79a9ec5763879ac499fd549d2cff022e59e37a848";
in
{
  home.activation.installDBeaver = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/DBeaver.app" ]; then
      _dmg=$(mktemp /tmp/dbeaver-XXXXXX.dmg)
      /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
      echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { rm -f "$_dmg"; exit 1; }
      _mnt=$(/usr/bin/mktemp -d /tmp/dbeaver-mnt-XXXXXX)
      /usr/bin/hdiutil attach "$_dmg" -mountpoint "$_mnt" -nobrowse -quiet
      /bin/cp -R "$_mnt/DBeaver.app" /Applications/
      /usr/bin/xattr -dr com.apple.quarantine /Applications/DBeaver.app
      /usr/bin/hdiutil detach "$_mnt" -quiet
      rm -f "$_dmg"
    fi
  '';
}
