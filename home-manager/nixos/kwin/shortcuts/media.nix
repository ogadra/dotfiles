{ ... }:
{
  # Audio and media control shortcuts
  programs.plasma.shortcuts = {
    kmix = {
      "decrease_microphone_volume" = "Microphone Volume Down";
      "decrease_volume" = "Volume Down";
      "decrease_volume_small" = "Shift+Volume Down";
      "increase_microphone_volume" = "Microphone Volume Up";
      "increase_volume" = "Volume Up";
      "increase_volume_small" = "Shift+Volume Up";
      "mic_mute" = [
        "Microphone Mute"
        "Meta+Volume Mute"
      ];
      "mute" = "Volume Mute";
    };
    mediacontrol = {
      "mediavolumedown" = [ ];
      "mediavolumeup" = [ ];
      "nextmedia" = "Media Next";
      "pausemedia" = "Media Pause";
      "playmedia" = [ ];
      "playpausemedia" = "Media Play";
      "previousmedia" = "Media Previous";
      "stopmedia" = "Media Stop";
    };
  };
}
