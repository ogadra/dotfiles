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
  environment.shells = [ pkgs.fish ];
  users.users.${username}.shell = pkgs.fish;

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

  # Homebrew integration (declarative management)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    brews = [
      "gitleaks"
      "gomi"
      "lefthook"
      "mise"
    ];

    casks = [
      # Add GUI apps here as needed
    ];
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

  # State version
  system.stateVersion = 5;
}
