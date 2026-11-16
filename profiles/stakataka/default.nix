{
  config,
  inputs,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./power.nix
  ];

  networking.hostName = "stakataka";

  system.activationScripts.postActivation.text = ''
    ${config.nix.package}/bin/nix-collect-garbage --delete-older-than 1d
  '';
}
