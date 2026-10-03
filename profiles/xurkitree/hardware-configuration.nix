# Placeholder so the flake evaluates; overwrite on xurkitree with `sudo nixos-generate-config --dir /etc/nixos` output and copy it here
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Typical desktop kernel modules; nixos-generate-config replaces this list with the probed ones
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    # Dummy UUID so evaluation succeeds; a real install needs the actual root UUID
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "ext4";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Redistributable firmware covers microcode and most desktop NIC/GPU blobs
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
