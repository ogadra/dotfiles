{ pkgs, ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  # Mesa's iris driver hangs this Intel Arrow Lake iGPU while wezterm paints and aborts before the window ever shows, while the Vulkan-backed WebGpu front end drives the same iGPU fine, so take it on Linux and leave macOS alone.
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
