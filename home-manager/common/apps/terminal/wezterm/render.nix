{ pkgs, ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  # WebGpu renders where Mesa's iris OpenGL path hangs this Arrow Lake iGPU before the window shows, and HighPerformance stops wgpu's LowPower default from picking the iGPU on hybrid Intel+NVIDIA boxes where KWin runs on the dGPU and rejects its dmabuf import with Wayland protocol error 7, so take both on Linux only.
  platformConfig =
    if isLinux then
      "    config.front_end = 'WebGpu'\n    config.webgpu_power_preference = 'HighPerformance'\n"
    else
      "";
in
{
  xdg.configFile."wezterm/render.lua".text = ''
        local module = {}

        function module.apply_to_config(config, wezterm)
    ${platformConfig}    end

        return module
  '';
}
