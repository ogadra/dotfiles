{ lib, ... }:
let
  version = "1.104.19";
  dmgUrl = "https://releases.raycast.com/releases/${version}/download?build=universal";
  dmgSha256 = "ba453b5b9553ca9f09a52f55efe10c863add5ff9466e5bbf12c506ad1da2fc82";
in
{
  targets.darwin.defaults."com.raycast.macos" = {
    # グローバルホットキー: Command-49 (Cmd+Space)
    raycastGlobalHotkey = "Command-49";

    raycastWindowPresentationMode = 2;

    # 優先ウィンドウモード
    raycastPreferredWindowMode = "default";

    # システムの外観 (ライト/ダーク) に追従する
    raycastShouldFollowSystemAppearance = 1;

    # メニューバーでハイパーキーアイコンを使わない
    useHyperKeyIcon = 0;

    # Raycast起動時に入力ソースをABCへ強制する
    enforcedInputSourceIDOnOpen = "com.apple.keylayout.ABC";

    # 絵文字ピッカーの肌の色
    emojiPicker_skinTone = "light";
  };

  home.activation.installRaycast = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/Raycast.app" ]; then
      _dmg=$(mktemp /tmp/raycast-XXXXXX.dmg)
      /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
      echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { rm -f "$_dmg"; exit 1; }
      _mnt=$(/usr/bin/mktemp -d /tmp/raycast-mnt-XXXXXX)
      /usr/bin/hdiutil attach "$_dmg" -mountpoint "$_mnt" -nobrowse -quiet
      /bin/cp -R "$_mnt/Raycast.app" /Applications/
      /usr/bin/xattr -dr com.apple.quarantine /Applications/Raycast.app
      /usr/bin/hdiutil detach "$_mnt" -quiet
      rm -f "$_dmg"
    fi
  '';
}
