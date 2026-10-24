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
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # CI pushes every profile build here, so patched packages are fetched instead of built locally
      extra-substituters = [ "https://ogadra-dotfiles.cachix.org" ];
      extra-trusted-public-keys = [
        "ogadra-dotfiles.cachix.org-1:hgpwhjgHgG8SdvBvqUvkXf0nWeSanlmM6htTOX86x6U="
      ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Shell configuration
  programs.zsh.enable = true;
  programs.fish.enable = true;
  environment.shells = [
    "/etc/profiles/per-user/${username}/bin/zsh"
    "/etc/profiles/per-user/${username}/bin/fish"
  ];
  users.users.${username}.shell = "/etc/profiles/per-user/${username}/bin/zsh";

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
