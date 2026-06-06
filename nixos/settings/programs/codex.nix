{ ... }:
let
  shared = ../../../home-manager/common/modules/llm-agent;
in
{
  environment.etc = {
    "codex/requirements.toml".source = ./codex/requirements.toml;
    "codex/hooks/pre-bash.sh" = {
      source = shared + "/scripts/pre-bash.sh";
      mode = "0555";
    };
    "codex/hooks/play-sound.sh" = {
      source = shared + "/scripts/play-sound.sh";
      mode = "0555";
    };
    "codex/hooks/git/check.sh" = {
      source = shared + "/scripts/git/check.sh";
      mode = "0555";
    };
    "codex/hooks/git/block-default-push.sh" = {
      source = shared + "/scripts/git/block-default-push.sh";
      mode = "0555";
    };
    "codex/hooks/git/block-no-verify.sh" = {
      source = shared + "/scripts/git/block-no-verify.sh";
      mode = "0555";
    };
    "codex/hooks/git/block-clone.sh" = {
      source = shared + "/scripts/git/block-clone.sh";
      mode = "0555";
    };
    "codex/hooks/gh/check.sh" = {
      source = shared + "/scripts/gh/check.sh";
      mode = "0555";
    };
    "codex/hooks/gh/block-repo-clone.sh" = {
      source = shared + "/scripts/gh/block-repo-clone.sh";
      mode = "0555";
    };
    "codex/sounds/notification.mp3".source = shared + "/sounds/notification.mp3";
    "codex/sounds/stop.mp3".source = shared + "/sounds/stop.mp3";
  };
}
