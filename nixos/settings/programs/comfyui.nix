{ ... }:
{
  # CDI spec that lets `docker run --device nvidia.com/gpu=all` in comfyui-serve reach the GPU
  hardware.nvidia-container-toolkit.enable = true;
}
