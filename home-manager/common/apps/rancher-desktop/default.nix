{ lib, nixLib, ... }:
let
  version = "1.25.0";
  dmgUrl = "https://github.com/rancher-sandbox/rancher-desktop/releases/download/v${version}/Rancher.Desktop-${version}.aarch64.dmg";
  dmgSha256 = "17b93863838fc3860d4adb0fa58a76a283011c3ea8743205b306e23f5282c671";
  settingsFile = "$HOME/Library/Preferences/rancher-desktop/settings.json";

  defaultsProfile = {
    version = 19;
    containerEngine.name = "moby";
    kubernetes.enabled = false;
    application.startInBackground = true;
    application.pathManagementStrategy = "manual";
    application.telemetry.enabled = false;
    application.updater.enabled = false;
  };
in
{
  home.sessionPath = [ "$HOME/.rd/bin" ];

  home.file."Library/Preferences/io.rancherdesktop.profile.defaults.plist".text =
    lib.generators.toPlist { escape = true; }
      defaultsProfile;

  launchd.agents.rancher-desktop = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/open"
        "-g"
        "-a"
        "Rancher Desktop"
      ];
      RunAtLoad = true;
    };
  };

  home.activation.installRancherDesktop = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/Rancher Desktop.app" ]; then
      _dmg=$(mktemp /tmp/rancher-desktop-XXXXXX.dmg)
      /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
      echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { rm -f "$_dmg"; exit 1; }
      _mnt=$(/usr/bin/mktemp -d /tmp/rancher-desktop-mnt-XXXXXX)
      /usr/bin/hdiutil attach "$_dmg" -mountpoint "$_mnt" -nobrowse -quiet
      /bin/cp -R "$_mnt/Rancher Desktop.app" /Applications/
      /usr/bin/xattr -dr com.apple.quarantine "/Applications/Rancher Desktop.app"
      /usr/bin/hdiutil detach "$_mnt" -quiet
      rm -f "$_dmg"
    fi

    if [ -f "${settingsFile}" ]; then
      ${nixLib.mergeJson settingsFile { application.startInBackground = true; }}
    fi
  '';
}
