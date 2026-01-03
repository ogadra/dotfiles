{
  pkgs,
  username,
  ...
}:
{
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    # Disable alt+arrow directory navigation
    bind --erase \e\[1\;3D  # Alt+Left
    bind --erase \e\[1\;3C  # Alt+Right
    bind --erase \e\[1\;3A  # Alt+Up
    bind --erase \e\[1\;3B  # Alt+Down
  '';

  users.users.${username}.shell = pkgs.fish;
}
