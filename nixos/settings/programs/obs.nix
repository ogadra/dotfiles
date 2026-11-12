{ ... }:
{
  programs.obs-studio = {
    enable = true;
    # Home Manager already installs obs-studio, so null keeps this module to the v4l2loopback setup only
    package = null;
    # Loads v4l2loopback with an "OBS Cam" device for OBS's Start Virtual Camera
    enableVirtualCamera = true;
  };
}
