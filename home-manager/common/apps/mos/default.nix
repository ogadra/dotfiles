{ lib, ... }:
let
  # Mos は Sparkle 形式の zip 配布で、URL にビルド日時が含まれるため version では組み立てられない
  zipUrl = "https://github.com/Caldis/Mos/releases/download/4.2.1/Mos.Versions.4.2.1-20260531.1.zip";
  zipSha256 = "2ea69e96f092e44dada93a55bda1cddab3329c527bbd5f06e00dfb78e953960a";
in
{
  targets.darwin.defaults."com.caldis.Mos" = {
    smooth = true; # スムーズスクロールを有効化
    reverse = false; # スクロール方向の反転を無効（ナチュラルにしない）
    duration = 3.9; # スクロールアニメーションの長さ
    speed = 3; # スクロール速度
    step = 35; # 1 ステップあたりのスクロール量
    precision = 1; # 精密スクロール
    dash = 0; # 加速スクロール（ダッシュ）
    toggle = 0; # 一時的にスムーズスクロールを切り替えるキー
    block = 0; # ブロックリスト方式
    allowlist = false; # 許可リスト方式
    hideStatusItem = false; # メニューバーアイコンの非表示
    optionsExist = "optionsExist"; # Mos が設定済みと判定するためのフラグ
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
