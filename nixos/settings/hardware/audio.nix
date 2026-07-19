{ ... }:
{
  # ThinkPad P14s Gen 6 (Realtek ALC257 / SOF HDA-DSP) は内蔵スピーカーと
  # ヘッドホンを相互排他な ACP プロファイルとして提供する。優先度既定では
  # ヘッドホン側が選ばれ、内蔵スピーカーの sink が表に出てこない。
  # 内蔵スピーカーを含むプロファイルを WirePlumber に固定させる。
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
