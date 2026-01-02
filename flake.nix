{
  description = "ogadra's Nix Configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    claude-code-overlay = {
      url = "github:ryoppippi/claude-code-overlay";
    };
  };

  outputs =
  {
    self,
    nixpkgs,
    home-manager,
    ...
  }@inputs:
    let
      nixosSystemArgs =
        {
          system,
          profile,
          username,
        }:
        import ./nixos {
          inherit
            inputs
            profile
            system
            username
            ;
        };
      inherit (nixpkgs.lib) nixosSystem;
    in
    {
      nixosConfigurations = {
        bisharp = nixosSystem (nixosSystemArgs {
          system   = "x86_64-linux";
          profile  = "bisharp";
          username = "ogadra";
        });
      };
    };
}
