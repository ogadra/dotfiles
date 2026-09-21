{ ... }:
{
  # The ThinkPad P14s Gen 6 (Realtek ALC257 / SOF HDA-DSP) exposes its speakers and headphones as mutually exclusive ACP profiles, and the default priorities pick headphones and hide the speaker sink, so pin WirePlumber to a profile that carries the speakers
  services.pipewire.wireplumber.extraConfig."51-audio-profile" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "device.name" = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"; }
        ];
        actions = {
          update-props = {
            "device.profile" = "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)";
          };
        };
      }
    ];
  };
}
