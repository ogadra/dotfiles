{ pkgs, ... }:
let
  # The binary name matches Exec= in the AppImage's Strata.desktop, so the desktop entry launches it unchanged
  pname = "strata-desktop";
  # v0.2.10 was released less than 3 days ago
  version = "0.2.9";

  src = pkgs.fetchurl {
    url = "https://github.com/Niko1221/Strata/releases/download/v${version}/Strata-${version}-linux-x86_64.AppImage";
    hash = "sha256-xSgxE8Mg5Ve/eWjZreYm3WHOowD8sbi2LvTV435tLak=";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };

  # The upstream flake only offers a devShell for building the engine from source, so wrap the release AppImage instead
  strata = pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    # wrapType2 installs only the binary, so copy the desktop entry and icon out of the AppImage
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/Strata.desktop $out/share/applications/strata-desktop.desktop
      install -Dm444 ${appimageContents}/usr/share/icons/hicolor/512x512/apps/strata-desktop.png \
        $out/share/icons/hicolor/512x512/apps/strata-desktop.png
    '';
  };
in
{
  home.packages = [ strata ];
}
