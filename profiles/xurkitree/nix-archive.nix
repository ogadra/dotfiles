{
  config,
  username,
  ...
}:
let
  archiveDir = "/mnt/nix-archive";
in
{
  fileSystems.${archiveDir} = {
    # By-id pins the SanDisk SSD itself, since sdX letters shift with the other SATA disks
    device = "/dev/disk/by-id/ata-SanDisk_SDSSDA240G_164286452202";
    fsType = "ext4";
    # Formats only a disk without any signature, so wiping the old NTFS stays a manual step
    autoFormat = true;
    # Boot continues without the SSD, and the timer below then fails instead of filling the root disk
    options = [ "nofail" ];
  };

  nix.settings = {
    # Trusted without signatures since only root writes it, and priority 10 is checked before the remote caches (40 and up)
    extra-substituters = [ "file://${archiveDir}?trusted=true&priority=10" ];
  };

  # Copies every generation's closure so paths removed by nix-collect-garbage can be substituted back
  systemd.services.nix-archive = {
    description = "Archive Nix profile generations to ${archiveDir}";
    unitConfig.RequiresMountsFor = archiveDir;
    serviceConfig.Type = "oneshot";
    path = [ config.nix.package ];
    # zstd over the default xz because xz takes hours for the ~90 GiB of closures
    script = ''
      nix copy --to 'file://${archiveDir}?compression=zstd' \
        /nix/var/nix/profiles/system-*-link \
        /home/${username}/.local/state/nix/profiles/*-link
    '';
  };

  # Daily keeps the archive close to current, since a manual run before every GC is easy to forget
  systemd.timers.nix-archive = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      # Runs a missed day at the next boot
      Persistent = true;
    };
  };
}
