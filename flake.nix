{
  description = "ogadra's Nix Configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
  {
    self,
    nixpkgs,
    nix-darwin,
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

      darwinSystemArgs =
        {
          system,
          profile,
          username,
        }:
        import ./darwin {
          inherit
            inputs
            profile
            system
            username
            ;
        };

      inherit (nixpkgs.lib) nixosSystem;
      inherit (nix-darwin.lib) darwinSystem;
    in
    {
      nixosConfigurations = {
        bisharp = nixosSystem (nixosSystemArgs {
          system   = "x86_64-linux";
          profile  = "bisharp";
          username = "ogadra";
        });
      };

      darwinConfigurations = {
        latias = darwinSystem (darwinSystemArgs {
          system   = "x86_64-darwin";
          profile  = "latias";
          username = "ogadra";
        });
        stakataka = darwinSystem (darwinSystemArgs {
          system   = "aarch64-darwin";
          profile  = "stakataka";
          username = "ogadra";
        });
      };
    };
}
