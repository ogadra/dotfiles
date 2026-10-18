{
  inputs,
  profile,
  system,
  username,
  isucon ? false,
  ...
}:
let
  baseModules = [
    ./configuration.nix
    ./settings/security/sudo.nix
    ../profiles/${profile}
  ];

  homeManagerModules = [
    inputs.home-manager.nixosModules.home-manager
    (import ../home-manager/default.nix {
      inherit
        profile
        username
        inputs
        isucon
        ;
    })
  ];

  allModules = baseModules ++ homeManagerModules;
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
