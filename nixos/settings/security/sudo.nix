{ ... }:
{
  # sudo時にrootのパスワードを要求
  security.sudo.extraConfig = ''
    Defaults rootpw
  '';
}
