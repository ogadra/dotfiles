{
  lib,
  pkgs,
  username,
  ...
}:
let
  email = "61941819+ogadra@users.noreply.github.com";

  shared = ../../modules/llm-agent;

  mkHook = name: {
    source = shared + "/hooks/${name}";
    executable = true;
  };
in
{
  # Signing keys come from GitHub so a key registered there is trusted on the next switch without editing this repo
  home.activation.fetchAllowedSigners = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    tmp=$(mktemp)
    # Keep the previous file when GitHub is unreachable so an offline switch still succeeds
    if ${pkgs.curl}/bin/curl -fsSL https://api.github.com/users/ogadra/ssh_signing_keys \
      | ${pkgs.jq}/bin/jq -r --arg email "${email}" '.[] | "\($email) \(.key)"' > "$tmp" && [ -s "$tmp" ]; then
      mkdir -p "$HOME/.ssh"
      chmod 644 "$tmp"
      mv -f "$tmp" "$HOME/.ssh/allowed_signers"
    else
      rm -f "$tmp"
    fi
  '';

  # Hooks for LLM agent sessions, reached through core.hooksPath in the .gitconfig those sessions load via GIT_CONFIG_GLOBAL.
  xdg.configFile = {
    "git/hooks-llm-agent/commit-msg" = mkHook "commit-msg";
    "git/hooks-llm-agent/pre-commit" = mkHook "pre-commit";
  };

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = username;
        inherit email;
      };

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
}
