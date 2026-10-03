{ inputs, ... }:
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  programs.plasma.enable = true;
  programs.plasma.kscreenlocker = {
    autoLock = false;
    lockOnResume = false;
  };
}
