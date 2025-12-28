{
  description = "ogadra's Nix Configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
  {
    self,
    nixpkgs,
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
            system
            profile
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
