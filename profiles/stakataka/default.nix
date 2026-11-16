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

  # Deletes generations older than 1 day every day at 03:15; interval takes launchd StartCalendarInterval keys
  nix.gc = {
    automatic = true;
    interval = {
      Hour = 3;
      Minute = 15;
    };
    options = "--delete-older-than 1d";
  };
}
