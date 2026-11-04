{ lib, pkgs, ... }:
let
  # v0.2.10 was released less than 3 days ago
  version = "0.2.9";
  # Control and engine versions shipped in the v0.2.9 release
  componentVersion = "0.1.55";
  engineFolder = "${componentVersion}-linux-x86_64-cuda-cuda13";

  releaseUrl = "https://github.com/Niko1221/Strata/releases/download/v${version}";

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

  # An FHS env instead of nix-ld, because the home-manager activation service and user units do not get NIX_LD
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

  # Revision and per-file SHA-256 pinned by setup.py of control 0.1.55, so setup recognises the files as its own IQ3_S
  modelUrl = "https://huggingface.co/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF/resolve/ed59f92082b1e93c0e96d60a8b11aab089b52f09";

  # Setup re-downloads any file without a <name>.done beside it and cannot write one into the store, so ship the marks too
  doneMark = pkgs.writeText "strata-done" "whole (fetched and SHA-256 checked by Nix)";

  shardName = i: "Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-0000${toString i}-of-00002.gguf";
  shardHashes = [
    "4c1eb2ceb4915e1192f4f386021897bde56a97f40a0bb78bb86465e0f7d2aca3"
    "316b46f3a2dbd68c900f43136ab9449f9dcc3725dfd8c794847c204bc161e113"
  ];

  # Symlinks rather than copies: setup only reads the shards, and writes its prepared pack under <data>/packs/
  strataShards = pkgs.linkFarm "strata-qwen3.8-flash-next-iq3_s" (
    lib.concatLists (
      lib.imap1 (i: sha256: [
        {
          name = shardName i;
          path = pkgs.fetchurl {
            url = "${modelUrl}/IQ3_S/${shardName i}";
            inherit sha256;
          };
        }
        {
          name = "${shardName i}.done";
          path = doneMark;
        }
      ]) shardHashes
    )
  );

  mmprojName = "mmproj-Qwen3.8-Flash-Next-BF16.gguf";
  strataMmproj = pkgs.fetchurl {
    url = "${modelUrl}/${mmprojName}";
    sha256 = "b1a82259702816a5330d7bd7607cd9676b11780e79ff7348c21103ff3ce49bd0";
  };

  # Setup's data folder holds models/<quant>/ for shards, models/ for the picture reader, and the packs/ and mtp/ it prepares
  dataDir = "Documents/Strata";

  # Loopback only: Open WebUI in nixos/settings/programs/strata.nix is the one client and the LAN entry point
  servePort = 8792;

  # IQ3_S wants ~60 GiB of RAM on this swapless 62 GiB PC, which froze the desktop; 44 GiB leaves ~7 GiB above the desktop's usual ~11 GiB
  memoryMax = "44G";
  # Reclaim starts here, a little below the hard cap, so the page cache shrinks before anything is killed
  memoryHigh = "42G";

  strataServeInner = pkgs.writeShellScript "strata-serve-inner" ''
    set -euo pipefail
    # Idempotent prepare; --low-ram mmap reads experts via the page cache the cgroup cap can reclaim, and 1536 MiB VRAM stays free for the display
    ${strataCli}/bin/strata install --family qwen --model IQ3_S --context 65536 --vram-reserve-mib 1536 \
      --low-ram mmap --data-dir "$HOME/${dataDir}" --yes --no-start
    # Setup writes the run config under the install folder, named after the model
    exec ${strataCli}/bin/strata serve --profile "$HOME/.local/share/strata/install/strata-iq3_s.json" \
      --host 127.0.0.1 --port ${toString servePort}
  '';

  # A foreground command in a transient scope: no service keeps the model resident, and unlike ulimit a cgroup counts the mmap'd page cache
  strataServe = pkgs.writeShellApplication {
    name = "strata-serve";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      exec systemd-run --user --scope --quiet --unit=strata-serve \
        -p MemoryHigh=${memoryHigh} -p MemoryMax=${memoryMax} ${strataServeInner}
    '';
  };
in
{
  home.packages = [
    strataCli
    strataServe
  ];

  home.file = {
    "${dataDir}/models/IQ3_S".source = strataShards;
    "${dataDir}/models/${mmprojName}".source = strataMmproj;
    "${dataDir}/models/${mmprojName}.done".source = doneMark;
  };

  # Hand the pinned feed to Strata's own updater rather than unpacking into components/, and only while no engine exists since a newer accepted feed refuses this one
  home.activation.installStrataEngine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _components="''${XDG_DATA_HOME:-$HOME/.local/share}/strata/components"
    if [ -z "$(ls -A "$_components/engine" 2>/dev/null)" ]; then
      # --quiet crashes in control 0.1.55 (_QuietCapture has no isatty), so print one JSON report instead of progress lines
      run ${strataCli}/bin/strata update --no-control --feed ${strataFeed} --components-dir "$_components" --output json
    fi
  '';
}
