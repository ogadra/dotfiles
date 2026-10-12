{ ... }:
{
  # ACP auto-profiles only pair each input mapping with each output mapping, so a GPU card can activate at most one HDMI/DP output and only one monitor's speaker ever shows up; PipeWire also reads profile sets from /etc/alsa-card-profile/profile-sets, so ship one with an explicit profile that bundles the outputs of all connected monitors
  environment.etc."alsa-card-profile/profile-sets/multi-hdmi.conf".text = ''
    [General]
    auto-profiles = yes

    [Mapping hdmi-stereo]
    description = Digital Stereo (HDMI)
    device-strings = hdmi:%f
    paths-output = hdmi-output-0
    channel-map = left,right
    priority = 9
    direction = output

    [Mapping hdmi-stereo-extra1]
    description = Digital Stereo (HDMI 2)
    device-strings = hdmi:%f,1
    paths-output = hdmi-output-1
    channel-map = left,right
    priority = 7
    direction = output

    [Mapping hdmi-stereo-extra2]
    description = Digital Stereo (HDMI 3)
    device-strings = hdmi:%f,2
    paths-output = hdmi-output-2
    channel-map = left,right
    priority = 7
    direction = output

    [Profile multi-hdmi]
    description = Digital Stereo (HDMI + HDMI 2 + HDMI 3) Output
    output-mappings = hdmi-stereo hdmi-stereo-extra1 hdmi-stereo-extra2
    priority = 9
    skip-probe = yes
  '';

  services.pipewire.wireplumber.extraConfig."50-multi-hdmi" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "device.name" = "alsa_card.pci-0000_02_00.1"; }
        ];
        actions = {
          update-props = {
            "api.alsa.use-acp" = true;
            # auto-profile/auto-port off so monitor hotplug cannot switch back to a single-output profile
            "api.acp.auto-profile" = false;
            "api.acp.auto-port" = false;
            "device.profile-set" = "multi-hdmi.conf";
            "device.profile" = "multi-hdmi";
          };
        };
      }
    ];
  };
}
