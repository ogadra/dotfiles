{
  description = "ogadra's Nix Configuration";
  inputs = {
    # Mesa 26.2.0 makes the iris driver hang the GPU on Meteor Lake (i915)
    # whenever wezterm renders through it; hold nixpkgs at the last revision
    # shipping Mesa 26.1.6 until a fixed Mesa lands in nixpkgs-unstable.
    nixpkgs.url = "github:NixOS/nixpkgs/104240a772428cc2e20d8fd86c9ddbb886bbaff2";
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
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
    nix-takt = {
      url = "github:ogadra/nix-takt";
    };
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stop-ai-slop-jp = {
      url = "github:iKora128/stop-ai-slop-jp";
      flake = false;
    };
    stop-slop = {
      url = "github:hardikpandya/stop-slop";
      flake = false;
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
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkNixLib = system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./lib { inherit (nixpkgs) lib; inherit pkgs; };

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
          nixLib = mkNixLib system;
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

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              gitleaks
              lefthook
            ];
          };
        }
      );
    };
}
