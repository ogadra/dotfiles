{ pkgs, lib, ... }:
let
  version = "0.0.424";
  dmgUrl = "https://stable.dl2.discordapp.net/distro/app/stable/osx/universal/${version}/Discord.dmg";
  dmgSha256 = "38617824808249eecce6377d6e467936bf695f62662dbcf372e95c930a7b7e4d";
in
{
  home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [ pkgs.discord ];

  home.activation.installDiscord = lib.mkIf (!pkgs.stdenv.hostPlatform.isLinux) (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "/Applications/Discord.app" ]; then
        _dmg=$(mktemp /tmp/discord-XXXXXX.dmg)
        /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
        echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { rm -f "$_dmg"; exit 1; }
        _mnt=$(/usr/bin/mktemp -d /tmp/discord-mnt-XXXXXX)
        /usr/bin/hdiutil attach "$_dmg" -mountpoint "$_mnt" -nobrowse -quiet
        /bin/cp -R "$_mnt/Discord.app" /Applications/
        /usr/bin/xattr -dr com.apple.quarantine /Applications/Discord.app
        /usr/bin/hdiutil detach "$_mnt" -quiet
        rm -f "$_dmg"
      fi
    ''
  );
}
