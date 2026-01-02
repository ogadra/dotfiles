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
    ../profiles/${profile}
  ];

  homeManagerModules = [
    inputs.home-manager.nixosModules.home-manager
    (import ../home-manager/default.nix {
      inherit
        profile
        username
        inputs
        ;
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
