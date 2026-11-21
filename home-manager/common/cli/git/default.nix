{
  config,
  lib,
  username,
  ...
}:
let
  shared = ../../modules/llm-agent;

  mkAgentHook = name: {
    source = shared + "/hooks/${name}";
    executable = true;
  };

  hooksDir = "${config.xdg.configHome}/git/hooks";

  mkHumanHook = name: {
    source = ./hooks + "/${name}";
    executable = true;
  };
in
{
  home.file.".ssh/allowed_signers".source = ./allowed_signers;

  xdg.configFile = {
    "git/hooks-llm-agent/commit-msg" = mkAgentHook "commit-msg";
    "git/hooks-llm-agent/pre-commit" = mkAgentHook "pre-commit";
    "git/hooks-llm-agent/pre-push" = mkAgentHook "pre-push";
    "git/hooks/pre-commit" = mkHumanHook "pre-commit";
    "git/hooks/pre-push" = mkHumanHook "pre-push";
    "git/hooks/run-repo-hook" = mkHumanHook "run-repo-hook";
  };

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = username;
        email = "61941819+ogadra@users.noreply.github.com";
      };

      core.hooksPath = hooksDir;

      init.defaultBranch = "main";
      push.default = "current";

      ghq.root = "~/codes";

      url."git@github.com:".insteadOf = "https://github.com/";
    };

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    settings.gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";

    ignores = import ./ignores.nix;
  };

  home.activation.captureLefthookHooks = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    for name in pre-commit pre-push; do
      hook="${hooksDir}/$name"
      if [ -f "$hook" ] && [ ! -L "$hook" ] && grep -q lefthook "$hook"; then
        run mv "$hook" "${hooksDir}/$name.lefthook"
      fi
    done
  '';
}
