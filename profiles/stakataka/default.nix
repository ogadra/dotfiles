{
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

  nix.gc = {
    automatic = true;
    interval = {
      Hour = 3;
      Minute = 15;
    };
    options = "--delete-older-than 1d";
  };
}
