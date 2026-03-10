{
  config,
  pkgs,
  username,
  ...
}:
{
  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Shell configuration
  programs.zsh.enable = true;
  programs.fish.enable = true;
  environment.shells = [
    "/etc/profiles/per-user/${username}/bin/fish"
  ];
  users.users.${username}.shell = "/etc/profiles/per-user/${username}/bin/fish";

  # macOS system defaults
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
    dock = {
      autohide = true;
      show-recents = false;
    };
    finder = {
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "Nlsv";
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
  ];

  # Primary user for darwin-rebuild
  system.primaryUser = username;

  # Trust additional CA certificates from /etc/ssl/certs
  security.pki.certificateFiles =
    let
      certDir = /etc/ssl/certs;
      entries = builtins.readDir certDir;
      pemFiles = builtins.filter (name: builtins.match ".*\\.pem$" name != null)
        (builtins.attrNames entries);
    in
    map (name: certDir + "/${name}") pemFiles;

  # State version
  system.stateVersion = 5;
}
