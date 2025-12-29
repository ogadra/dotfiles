{
  inputs,
  profile,
  system,
  username,
  ...
}:
let
  homeConfig = import ../home-manager {
    inherit
      profile
      username
      ;
  };
  homeManager = inputs.home-manager.nixosModules.home-manager;
in
{
  inherit system;

  modules = [
    ./configuration.nix
    ../profiles/${profile}
    homeConfig
    homeManager
  ];
}
