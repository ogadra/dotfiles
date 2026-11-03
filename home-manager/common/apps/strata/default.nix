{ lib, pkgs, ... }:
let
  # The binary name matches Exec= in the AppImage's Strata.desktop, so the desktop entry launches it unchanged
  pname = "strata-desktop";
  # v0.2.10 was released less than 3 days ago
  version = "0.2.9";
  # Control and engine versions shipped in the v0.2.9 release
  componentVersion = "0.1.55";
  engineFolder = "${componentVersion}-linux-x86_64-cuda-cuda13";

  releaseUrl = "https://github.com/Niko1221/Strata/releases/download/v${version}";

  src = pkgs.fetchurl {
    url = "${releaseUrl}/Strata-${version}-linux-x86_64.AppImage";
    hash = "sha256-xSgxE8Mg5Ve/eWjZreYm3WHOowD8sbi2LvTV435tLak=";
  };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };

  # The upstream flake only offers a devShell for building the engine from source, so wrap the release AppImage instead
  strata = pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    # Libraries the bundled GTK/GStreamer stack links against but neither the AppImage nor the default FHS env ships
    extraPkgs =
      pkgs: with pkgs; [
        libgpg-error
        e2fsprogs
        gmp
      ];

    # wrapType2 installs only the binary, so copy the desktop entry and icon out of the AppImage
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/Strata.desktop $out/share/applications/strata-desktop.desktop
      install -Dm444 ${appimageContents}/usr/share/icons/hicolor/512x512/apps/strata-desktop.png \
        $out/share/icons/hicolor/512x512/apps/strata-desktop.png
    '';
  };

  # runCommand skips fixup, which would otherwise patchelf and strip the bundled relocatable CPython
  strataControl = pkgs.runCommand "strata-control-${componentVersion}" { } ''
    mkdir -p $out
    tar -xzf ${
      pkgs.fetchurl {
        url = "${releaseUrl}/strata-control-${componentVersion}-linux-x86_64.tar.gz";
        hash = "sha256-UHg9L6bG6Y6b3I1PZq0HBwax4fPl4ngsxZ/V2r2UiOg=";
      }
    } -C $out
  '';

  # An FHS env instead of nix-ld, because the home-manager activation service does not get NIX_LD
  strataCli = pkgs.buildFHSEnv {
    name = "strata";
    targetPkgs =
      pkgs: with pkgs; [
        stdenv.cc.cc.lib
        zlib
      ];
    runScript = "${strataControl}/bin/strata";
  };

  # The updater rejects feed entries whose real path leaves the feed folder, so copy the files instead of symlinking them
  strataFeed = pkgs.runCommand "strata-feed-${version}" { } ''
    mkdir -p $out
    cp ${
      pkgs.fetchurl {
        url = "${releaseUrl}/strata-feed.json";
        hash = "sha256-BcwbIofmn9FifP31/qzbJwj83Ub5pbnHf+a9tZK6QBQ=";
      }
    } $out/strata-feed.json
    cp ${
      pkgs.fetchurl {
        url = "${releaseUrl}/strata-feed.json.sig";
        hash = "sha256-1nGpXFjiPpotqWF3LtdkqX/BAV9f/KdC5/MWNryoTQo=";
      }
    } $out/strata-feed.json.sig
    cp ${
      pkgs.fetchurl {
        url = "${releaseUrl}/strata-engine-${engineFolder}.tar.gz";
        hash = "sha256-zoayOyakUhoYcREwV1NLijTAHfCse5Fq3M+bHIwGj5I=";
      }
    } $out/strata-engine-${engineFolder}.tar.gz
  '';

  # Revision and per-file SHA-256 pinned by setup.py of control 0.1.55, so the app recognises the files as its own IQ3_S
  modelUrl = "https://huggingface.co/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF/resolve/ed59f92082b1e93c0e96d60a8b11aab089b52f09";

  # Symlinks rather than copies: setup reads an existing model folder in place and only warns when it is read-only
  strataModel = pkgs.linkFarm "strata-qwen3.8-flash-next-iq3_s" [
    {
      name = "Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00001-of-00002.gguf";
      path = pkgs.fetchurl {
        url = "${modelUrl}/IQ3_S/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00001-of-00002.gguf";
        sha256 = "4c1eb2ceb4915e1192f4f386021897bde56a97f40a0bb78bb86465e0f7d2aca3";
      };
    }
    {
      name = "Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00002-of-00002.gguf";
      path = pkgs.fetchurl {
        url = "${modelUrl}/IQ3_S/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00002-of-00002.gguf";
        sha256 = "316b46f3a2dbd68c900f43136ab9449f9dcc3725dfd8c794847c204bc161e113";
      };
    }
    {
      name = "mmproj-Qwen3.8-Flash-Next-BF16.gguf";
      path = pkgs.fetchurl {
        url = "${modelUrl}/mmproj-Qwen3.8-Flash-Next-BF16.gguf";
        sha256 = "b1a82259702816a5330d7bd7607cd9676b11780e79ff7348c21103ff3ce49bd0";
      };
    }
  ];
in
{
  home.packages = [ strata ];

  # Beside the app's default library so its folder picker opens next to it
  home.file."Documents/Strata/Models/Qwen3.8-Flash-Next-IQ3_S".source = strataModel;

  # Hand the pinned feed to the app's own updater rather than unpacking into components/, and only while no engine exists since the app takes over updates and refuses older feeds
  home.activation.installStrataEngine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _components="''${XDG_DATA_HOME:-$HOME/.local/share}/strata/components"
    if [ -z "$(ls -A "$_components/engine" 2>/dev/null)" ]; then
      # --quiet crashes in control 0.1.55 (_QuietCapture has no isatty), so print one JSON report instead of progress lines
      run ${strataCli}/bin/strata update --no-control --feed ${strataFeed} --components-dir "$_components" --output json
    fi
  '';
}
