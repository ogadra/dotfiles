{ pkgs, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
  # Mesa's iris OpenGL driver hangs this Intel Arrow Lake iGPU while wezterm
  # paints (i915 logs "GPU HANG: ... in wezterm-gui") and aborts the process
  # when the batch flush cannot recover, so the window dies before showing
  # anything. The Vulkan-backed WebGpu front end drives the same iGPU without
  # hanging, so prefer it on Linux and leave macOS on the default front end.
  platformConfig = if isLinux then "    config.front_end = 'WebGpu'\n" else "";
in
{
  xdg.configFile."wezterm/render.lua".text = ''
    local module = {}

    function module.apply_to_config(config, wezterm)
${platformConfig}    end

    return module
  '';
}
