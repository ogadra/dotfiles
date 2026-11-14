{ ... }:
{
  # CDI spec that lets `docker run --device nvidia.com/gpu=all` in comfyui-serve reach the GPU
  hardware.nvidia-container-toolkit.enable = true;

  # ComfyUI's web UI for phones on the LAN
  networking.firewall.allowedTCPPorts = [ 8188 ];
}
