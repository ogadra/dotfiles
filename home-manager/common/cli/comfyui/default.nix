{ pkgs, ... }:
let
  # A prebuilt image instead of nixpkgs' comfyui, whose CUDA build is not in the public cache; the newer 20261104 tag is less than 3 days old
  image = "yanwk/comfyui-boot:cu130-slim-v2-20261027@sha256:9c222bf018d44b9490a1e21f832e6555f4845ebd34c57cb2371a6fb246f99e98";

  # Same cap as strata-serve: this swapless 62 GiB PC froze when one process took nearly all RAM
  memoryMax = "44g";

  # Models, outputs and custom nodes live here, so a new image keeps them
  dataDir = "Documents/ComfyUI";

  # Outside /root/ComfyUI because the image's startup chowns everything mounted under it to root, which would stop the user adding checkpoints
  extraModelPaths = pkgs.writeText "extra_model_paths.yaml" ''
    user:
      checkpoints: /root/user-checkpoints
  '';

  # A foreground command instead of a service, because the GPU has room for only one of ComfyUI and strata-serve
  comfyuiServe = pkgs.writeShellApplication {
    name = "comfyui-serve";
    text = ''
      data="$HOME/${dataDir}"
      mkdir -p "$data"/{cache,config,local,custom_nodes,models,user-checkpoints,hf-hub,torch-hub,input,output,user,user-scripts}
      # IPv4 only for phones on the LAN: a bare -p would also bind this PC's global IPv6 address, and ComfyUI has no login
      exec docker run -it --rm --name comfyui \
        --device nvidia.com/gpu=all \
        --memory=${memoryMax} \
        -p 0.0.0.0:8188:8188 \
        -v "$data/cache:/root/.cache" \
        -v "$data/config:/root/.config" \
        -v "$data/local:/root/.local" \
        -v "$data/custom_nodes:/root/ComfyUI/custom_nodes" \
        -v "$data/models:/root/ComfyUI/models" \
        -v "$data/user-checkpoints:/root/user-checkpoints" \
        -v ${extraModelPaths}:/root/extra_model_paths.yaml:ro \
        -v "$data/hf-hub:/root/.cache/huggingface/hub" \
        -v "$data/torch-hub:/root/.cache/torch/hub" \
        -v "$data/input:/root/ComfyUI/input" \
        -v "$data/output:/root/ComfyUI/output" \
        -v "$data/user:/root/ComfyUI/user" \
        -v "$data/user-scripts:/root/user-scripts" \
        -e CLI_ARGS="--fast --extra-model-paths-config /root/extra_model_paths.yaml" \
        ${image}
    '';
  };
in
{
  home.packages = [ comfyuiServe ];
}
