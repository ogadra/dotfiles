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
    # Redirect SNS domains to loopback during the competition
    ++ inputs.nixpkgs.lib.optional isucon {
      networking.extraHosts = ''
        127.0.0.1 twitter.com www.twitter.com x.com www.x.com
        ::1 twitter.com www.twitter.com x.com www.x.com
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
