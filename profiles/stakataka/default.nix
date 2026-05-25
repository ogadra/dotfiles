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
}
