{ ... }:
{
  # Strata's API share; it listens on IPv4 0.0.0.0 only, so the global IPv6 address does not expose it beyond the LAN
  networking.firewall.allowedTCPPorts = [ 8792 ];
}
