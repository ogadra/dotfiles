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

  # Setup downloads the model into this data folder at its own pinned revision and SHA-256, because 84.5 GB in the closure overflows CI runners and cachix
  dataDir = "Documents/Strata";

  # Loopback only: Open WebUI in nixos/settings/programs/strata.nix is the one client and the LAN entry point
  servePort = 8792;

  # IQ3_S wants ~60 GiB of RAM on this swapless 62 GiB PC, which froze the desktop; 44 GiB leaves ~7 GiB above the desktop's usual ~11 GiB
  memoryMax = "44G";
  # Reclaim starts here, a little below the hard cap, so the page cache shrinks before anything is killed
  memoryHigh = "42G";

  # Run by Strata before it loads the model: wait for ComfyUI's jobs, then make it give the VRAM back; a stopped ComfyUI holds nothing, so curl failing just ends the wait
  comfyuiYield = pkgs.writeShellApplication {
    name = "strata-comfyui-yield";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
    ];
    text = ''
      comfyui=http://127.0.0.1:8188
      while queue=$(curl -fsS --max-time 5 "$comfyui/queue"); do
        if [ "$(jq '(.queue_running | length) + (.queue_pending | length)' <<<"$queue")" -eq 0 ]; then
          break
        fi
        sleep 3
      done
      curl -fsS --max-time 5 -H "Content-Type: application/json" \
        -d '{"unload_models":true,"free_memory":true}' "$comfyui/free" || true
    '';
  };

  # Seconds a ComfyUI job may keep Strata waiting before the request gets a 503
  yieldTimeoutS = 600;
  # MiB free before loading; below what the model needs at start, so ComfyUI's leftovers refuse the load instead of running it out of memory
  minFreeVramMib = 12000;

  strataServeInner = pkgs.writeShellScript "strata-serve-inner" ''
    set -euo pipefail
    # Idempotent prepare; --low-ram mmap reads experts via the page cache the cgroup cap can reclaim, and 1536 MiB VRAM stays free for the display
    ${strataCli}/bin/strata install --family qwen --model IQ3_S --context 65536 --vram-reserve-mib 1536 \
      --low-ram mmap --data-dir "$HOME/${dataDir}" --yes --no-start
    # Setup writes the run config under the install folder, named after the model, and rewrites it on every install, so add the GPU sharing keys afterwards
    config="$HOME/.local/share/strata/install/strata-iq3_s.json"
    ${pkgs.jq}/bin/jq '. + {lazy_load: true, before_load: ["${comfyuiYield}/bin/strata-comfyui-yield"], before_load_timeout_s: ${toString yieldTimeoutS}, min_free_vram_mib: ${toString minFreeVramMib}}' \
      "$config" > "$config.tmp"
    mv "$config.tmp" "$config"
    exec ${strataCli}/bin/strata serve --profile "$config" \
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

  # Hand the pinned feed to Strata's own updater rather than unpacking into components/, and only while no engine exists since a newer accepted feed refuses this one
  home.activation.installStrataEngine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _components="''${XDG_DATA_HOME:-$HOME/.local/share}/strata/components"
    if [ -z "$(ls -A "$_components/engine" 2>/dev/null)" ]; then
      # --quiet crashes in control 0.1.55 (_QuietCapture has no isatty), so print one JSON report instead of progress lines
      run ${strataCli}/bin/strata update --no-control --feed ${strataFeed} --components-dir "$_components" --output json
    fi
  '';
}
