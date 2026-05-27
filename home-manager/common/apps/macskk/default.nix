{ lib, pkgs, ... }:
let
  version = "2.15.0";
  dmgUrl = "https://github.com/mtgto/macSKK/releases/download/${version}/macSKK-${version}.dmg";
  dmgSha256 = "114cbb9892ff41100bfbd50db61c4761ca1829c8f9b2a49e396419b813d19ac8";

  # Input Methodは~/Library/Input Methods/配下に置けばsudo不要
  installDir = "$HOME/Library/Input Methods";
  appName = "macSKK.app";

  # SKK-JISYO.L (EUC-JP) をstoreに固定し、UTF-8変換版をderivationで生成。
  # macSKKのサンドボックスは ~/Library/Containers/.../Dictionaries/ から辞書を読み込む。
  skkJisyoEuc = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/skk-dev/dict/master/SKK-JISYO.L";
    sha256 = "c791f578d1b4040fce282db29bc22b2cc7ea46f83e269fab2e0fa779e2967e40";
  };
  skkJisyoUtf8 = pkgs.runCommand "skk-jisyo-utf8" { } ''
    ${pkgs.libiconv}/bin/iconv -f EUC-JP -t UTF-8 ${skkJisyoEuc} > $out
  '';

  dictDir = "$HOME/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries";
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

  # macSKKのサンドボックスContainersはmacSKK初回起動後にmacOSが作成するため、
  # ディレクトリが無ければ何もしない（再ログイン後の2回目のactivationで配置される）。
  home.activation.installMacSKKDict = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${dictDir}" ] && [ ! -s "${dictDir}/skk-jisyo.utf8" ]; then
      /bin/cp ${skkJisyoUtf8} "${dictDir}/skk-jisyo.utf8"
      /bin/chmod 644 "${dictDir}/skk-jisyo.utf8"
    fi
  '';
}
