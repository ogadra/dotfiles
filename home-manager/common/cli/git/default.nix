{
  username,
  ...
}:
{
  home.file.".ssh/allowed_signers".source = ./allowed_signers;

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

    extraConfig.gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";

    ignores = import ./ignores.nix;
  };
}
