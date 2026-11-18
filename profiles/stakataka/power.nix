{ ... }:
{
  # Blocks sleep and lid-close sleep on both AC and battery so WiFi and background work carry on; postActivation because nix-darwin skips custom-named scripts
  system.activationScripts.postActivation.text = ''
    /usr/bin/pmset -a sleep 0
    /usr/bin/pmset -a disksleep 0
    /usr/bin/pmset -a displaysleep 30
    /usr/bin/pmset -a disablesleep 1
    /usr/bin/pmset -a tcpkeepalive 1
    /usr/bin/pmset -a powernap 1
    /usr/bin/pmset -a womp 1
  '';
}
