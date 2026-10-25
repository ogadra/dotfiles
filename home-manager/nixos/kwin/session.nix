{ ... }:
{
  # A restored espanso launcher races the systemd espanso service and loops the "already running" dialog; entries are desktop file IDs
  programs.plasma.session.sessionRestore.excludeApplications = [ "espanso.desktop" ];
}
