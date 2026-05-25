{ lib, pkgs, ... }:
let
  version = "2.15.0";
  dmgUrl = "https://github.com/mtgto/macSKK/releases/download/${version}/macSKK-${version}.dmg";
  dmgSha256 = "114cbb9892ff41100bfbd50db61c4761ca1829c8f9b2a49e396419b813d19ac8";

  # Input Methodは~/Library/Input Methods/配下に置けばsudo不要
  installDir = "$HOME/Library/Input Methods";
  appName = "macSKK.app";
in
lib.mkIf pkgs.stdenv.isDarwin {
  home.activation.installMacSKK = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _dest="${installDir}/${appName}"
    if [ ! -d "$_dest" ]; then
      /bin/mkdir -p "${installDir}"
      _dmg=$(/usr/bin/mktemp /tmp/macskk-XXXXXX.dmg)
      /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
      echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { rm -f "$_dmg"; exit 1; }
      # DMG内は .pkg インストーラなので、ボリューム名は固定指定せず動的に取得する
      _mnt=$(/usr/bin/hdiutil attach "$_dmg" -nobrowse -readonly | /usr/bin/awk -F'\t' '$NF ~ /^\/Volumes\// {print $NF}' | /usr/bin/tail -1)
      _pkg=$(/usr/bin/find "$_mnt" -maxdepth 2 -name '*.pkg' -type f | /usr/bin/head -1)
      if [ -z "$_pkg" ]; then
        /usr/bin/hdiutil detach "$_mnt" -quiet || true
        rm -f "$_dmg"
        exit 1
      fi
      # pkgのペイロードを展開してmacSKK.appを取り出す (sudo不要)
      _extract=$(/usr/bin/mktemp -d /tmp/macskk-extract-XXXXXX)
      /usr/sbin/pkgutil --expand-full "$_pkg" "$_extract/pkg"
      _app=$(/usr/bin/find "$_extract" -name "${appName}" -type d | /usr/bin/head -1)
      if [ -z "$_app" ]; then
        /usr/bin/hdiutil detach "$_mnt" -quiet || true
        /bin/rm -rf "$_extract" "$_dmg"
        exit 1
      fi
      /bin/cp -R "$_app" "${installDir}/"
      /usr/bin/hdiutil detach "$_mnt" -quiet
      /bin/rm -rf "$_extract"
      /bin/rm -f "$_dmg"
    fi
  '';
}
