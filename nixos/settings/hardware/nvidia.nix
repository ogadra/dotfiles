{ ... }:
{
  # nouveau does not deliver HDMI/DP audio on this card (GB203 Blackwell): the sinks appear and streams run but no audio reaches the monitors, so use the proprietary driver instead
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;
  hardware.nvidia = {
    # Blackwell is only supported by the open kernel modules; the proprietary ones refuse to load
    open = true;
    # Required for the Wayland session; without it the compositor cannot drive the displays
    modesetting.enable = true;
  };
}
