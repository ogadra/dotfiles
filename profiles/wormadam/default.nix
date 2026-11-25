{ config, ... }:
{
  networking.hostName = "wormadam";

  system.activationScripts.postActivation.text = ''
    ${config.nix.package}/bin/nix-collect-garbage --delete-older-than 1d
  '';
}
