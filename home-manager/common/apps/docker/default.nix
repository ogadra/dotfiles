{ lib, pkgs, ... }:
let
  version = "4.71.0";
  build = "225177";
  dmgUrl = "https://desktop.docker.com/mac/main/arm64/${build}/Docker.dmg";
  dmgSha256 = "56a78b132696b747c40b151af57ecdbd8529b5f4dac4d436cd0d767721a957b4";
in
lib.mkIf pkgs.stdenv.isDarwin {
  home.activation.installDockerDesktop = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/Docker.app" ]; then
      _dmg=$(mktemp /tmp/docker-XXXXXX.dmg)
      echo "Downloading Docker Desktop ${version}..."
      /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
      echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { echo "SHA256 mismatch!"; rm -f "$_dmg"; exit 1; }
      _mnt=$(/usr/bin/mktemp -d /tmp/docker-mnt-XXXXXX)
      /usr/bin/hdiutil attach "$_dmg" -mountpoint "$_mnt" -quiet
      /usr/bin/sudo /bin/cp -R "$_mnt/Docker.app" /Applications/
      /usr/bin/hdiutil detach "$_mnt" -quiet
      rm -f "$_dmg"
    fi
  '';
}
