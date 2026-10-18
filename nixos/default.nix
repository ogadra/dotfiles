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

  allModules =
    baseModules
    ++ homeManagerModules
    # Prevent SNS access during the competition; 0.0.0.0 fails faster than a DNS sinkhole
    ++ inputs.nixpkgs.lib.optional isucon {
      networking.extraHosts = ''
        0.0.0.0 twitter.com www.twitter.com
        0.0.0.0 x.com www.x.com
      '';
    };
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
