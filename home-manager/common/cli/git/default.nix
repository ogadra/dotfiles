{
  username,
  ...
}:
{
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
    };

    signing = {
      format        = "ssh";
      key           = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
  };
}
