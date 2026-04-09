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
    ./settings/activitymonitor.nix
    ./settings/clock.nix
    ./settings/controlcenter.nix
    ./settings/dock.nix
    ./settings/finder.nix
    ./settings/globalpreferences.nix
    ./settings/hitoolbox.nix
    ./settings/hotcorner.nix
    ./settings/keyboard.nix
    ./settings/launchservices.nix
    ./settings/login.nix
    ./settings/screensaver.nix
    ./settings/screenshot.nix
    ./settings/softwareupdate.nix
    ./settings/spaces.nix
    ./settings/trackpad.nix
    ./settings/universalaccess.nix
    ./settings/window-manager.nix
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
