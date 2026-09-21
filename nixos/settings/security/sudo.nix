{ ... }:
{
  # Asks for the root password rather than the user's on sudo
  security.sudo.extraConfig = ''
    Defaults rootpw
  '';
}
