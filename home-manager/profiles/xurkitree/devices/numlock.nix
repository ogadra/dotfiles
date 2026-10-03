{ inputs, ... }:
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  programs.plasma.enable = true;
  # numlockOnStartup accepts: on, off, unchanged
  programs.plasma.input.keyboard.numlockOnStartup = "off";
}
