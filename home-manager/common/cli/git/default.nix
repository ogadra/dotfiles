{
  username,
  ...
}:
let
  shared = ../../modules/llm-agent;

  mkHook = name: {
    source = shared + "/hooks/${name}";
    executable = true;
  };
in
{
  home.file.".ssh/allowed_signers".source = ./allowed_signers;

  # Hooks for LLM agent sessions, reached through core.hooksPath in the .gitconfig those sessions load via GIT_CONFIG_GLOBAL.
  xdg.configFile = {
    "git/hooks-llm-agent/commit-msg" = mkHook "commit-msg";
    "git/hooks-llm-agent/pre-commit" = mkHook "pre-commit";
  };

  programs.git = {
    enable = true;

    settings = {
      user = {
        name  = username;
        email = "61941819+ogadra@users.noreply.github.com";
      };

      init.defaultBranch = "main";
      push.default = "current";

      ghq.root = "~/codes";

      url."git@github.com:".insteadOf = "https://github.com/";
    };

    signing = {
      format        = "ssh";
      key           = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    settings.gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";

    ignores = import ./ignores.nix;
  };
}
