{ isucon, ... }:
let
  shared = ../../../home-manager/common/modules/llm-agent;
in
{
  environment.etc = {
    "codex/requirements.toml".source = ./codex/requirements.toml;
    "codex/hooks/pre-bash.sh" = {
      source = shared + "/scripts/pre-bash.sh";
    };
    "codex/hooks/normalize.sh" = {
      source = shared + "/scripts/normalize.sh";
    };
    "codex/hooks/play-sound.sh" = {
      source = shared + "/scripts/play-sound.sh";
    };
    "codex/hooks/git/check.sh" = {
      source = shared + "/scripts/git/check.sh";
    };
    "codex/hooks/git/block-default-commit.sh" = {
      source = shared + "/scripts/git/block-default-commit.sh";
    };
    "codex/hooks/git/block-default-push.sh" = {
      source = shared + "/scripts/git/block-default-push.sh";
    };
    "codex/hooks/git/block-force-push.sh" = {
      source = shared + "/scripts/git/block-force-push.sh";
    };
    "codex/hooks/git/block-rewrite-pushed.sh" = {
      source = shared + "/scripts/git/block-rewrite-pushed.sh";
    };
    "codex/hooks/git/block-clone.sh" = {
      source = shared + "/scripts/git/block-clone.sh";
    };
    "codex/hooks/git/block-worktree-outside.sh" = {
      source = shared + "/scripts/git/block-worktree-outside.sh";
    };
    "codex/hooks/gh/check.sh" = {
      source = shared + "/scripts/gh/check.sh";
    };
    "codex/hooks/gh/block-repo-clone.sh" = {
      source = shared + "/scripts/gh/block-repo-clone.sh";
    };
    "codex/hooks/gh/block-pr-close.sh" = {
      source = shared + "/scripts/gh/block-pr-close.sh";
    };
    "codex/sounds/notification.mp3".source = ../../../home-manager/common/sounds/notification.mp3;
    "codex/sounds/stop.mp3".source = ../../../home-manager/common/sounds/stop.mp3;
  }
  // (
    if isucon then
      { }
    else
      {
        "codex/hooks/block-sudo.sh" = {
          source = shared + "/scripts/block-sudo.sh";
        };
        "codex/hooks/git/block-no-verify.sh" = {
          source = shared + "/scripts/git/block-no-verify.sh";
        };
        "codex/hooks/git/block-merge-non-base.sh" = {
          source = shared + "/scripts/git/block-merge-non-base.sh";
        };
        "codex/hooks/git/block-cherry-pick-stacked.sh" = {
          source = shared + "/scripts/git/block-cherry-pick-stacked.sh";
        };
        "codex/hooks/git/block-commit-all.sh" = {
          source = shared + "/scripts/git/block-commit-all.sh";
        };
        "codex/hooks/git/block-bulk-add.sh" = {
          source = shared + "/scripts/git/block-bulk-add.sh";
        };
        "codex/hooks/gh/block-pr-body.sh" = {
          source = shared + "/scripts/gh/block-pr-body.sh";
        };
      }
  );
}
