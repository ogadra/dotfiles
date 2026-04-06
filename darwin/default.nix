{
  inputs,
  profile,
  system,
  username,
  ...
}:
let
  baseModules = [
    ./configuration.nix
    ./settings/keyboard.nix
    ./settings/dock.nix
    ./settings/hotcorner.nix
    ./settings/finder.nix
    ./settings/screenshot.nix
    ./settings/clock.nix
    ./settings/window-manager.nix
    ./settings/trackpad.nix
    ./settings/login.nix
    ./settings/controlcenter.nix
    ../profiles/${profile}
  ];

  homeManagerModules = [
    inputs.home-manager.darwinModules.home-manager
    ({ lib, ... }: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${username} = {
          imports = [ ../home-manager/profiles/${profile} ];
          home.username = username;
          home.homeDirectory = lib.mkForce "/Users/${username}";
        };
        extraSpecialArgs = {
          inherit username inputs;
        };
      };
    })
  ];

  allModules =
    baseModules
    ++ homeManagerModules
    ;
in
{
  inherit system;

  specialArgs = {
    inherit
      inputs
      profile
      username
      ;
  };

  modules = allModules;
}
