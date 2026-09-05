{
  lib,
  pkgs,
  ...
}:
let
  version = "1.4.194";
  releaseUrl = "https://github.com/stablyai/orca/releases/download/v${version}";

  appImage = pkgs.fetchurl {
    url = "${releaseUrl}/orca-linux.AppImage";
    hash = "sha256-HH91Nhx0PQ1NVhiCi3Tkh3340jrf3Dnrl9RxFzMzkWw=";
  };

  appImageContents = pkgs.appimageTools.extractType2 {
    pname = "orca-ide";
    inherit version;
    src = appImage;
  };

  orca = pkgs.appimageTools.wrapType2 {
    pname = "orca-ide";
    inherit version;
    src = appImage;

    extraInstallCommands = ''
      install -Dm444 ${appImageContents}/orca-ide.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/orca-ide.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=orca-ide'
      cp -r ${appImageContents}/usr/share/icons $out/share/
    '';
  };

  dmgUrl = "${releaseUrl}/orca-macos-arm64.dmg";
  dmgSha256 = "684e9241dd9e11db842b366b66c4dd463d8e588995fb51597c2974804513c768";
in
lib.mkMerge [
  (lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [ orca ];
  })

  (lib.mkIf pkgs.stdenv.isDarwin {
    home.activation.installOrca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "/Applications/Orca.app" ]; then
        _dmg=$(mktemp /tmp/orca-XXXXXX.dmg)
        /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
        echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { rm -f "$_dmg"; exit 1; }
        _mnt=$(/usr/bin/mktemp -d /tmp/orca-mnt-XXXXXX)
        /usr/bin/hdiutil attach "$_dmg" -mountpoint "$_mnt" -nobrowse -quiet
        /bin/cp -R "$_mnt/Orca.app" /Applications/
        /usr/bin/xattr -dr com.apple.quarantine /Applications/Orca.app
        /usr/bin/hdiutil detach "$_mnt" -quiet
        rm -f "$_dmg"
      fi
    '';
  })
]
