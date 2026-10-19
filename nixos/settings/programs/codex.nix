{ pkgs, isucon, ... }:
let
  shared = ../../../home-manager/common/modules/llm-agent;
in
{
  environment.etc = {
    "codex/requirements.toml".source = ./codex/requirements.toml;
    "codex/hooks/play-sound.sh" = {
      source = shared + "/scripts/play-sound.sh";
    };
    "codex/sounds/notification.mp3".source = ../../../home-manager/common/sounds/notification.mp3;
    "codex/sounds/stop.mp3".source = ../../../home-manager/common/sounds/stop.mp3;
  }
  // import (shared + "/scripts.nix") {
    inherit pkgs isucon;
    dir = "codex/hooks";
  };
}
