{ config, pkgs, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Wireless support via wpa_supplicant
  # networking.wireless.enable = true;

  # Network proxy
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Asia/Tokyo";

  # X11 windowing system; can go once the Wayland session is the only one in use
  services.xserver.enable = true;

  # KDE Plasma desktop environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # CUPS, for printing
  services.printing.enable = true;

  # Sound through pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # For JACK applications
    #jack.enable = true;
    # The example session manager, on by default since nothing else is packaged
    #media-session.enable = true;
  };

  # Touchpad support, already on in most desktopManagers
  # services.xserver.libinput.enable = true;

  # User account; set a password with `passwd`
  users.users.ogadra = {
    isNormalUser = true;
    description = "ogadra";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Packages in the system profile; search with `nix search wget`
  environment.systemPackages = with pkgs; [
    net-tools
  ];

  # Programs needing SUID wrappers or a user session
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # OpenSSH daemon
  # services.openssh.enable = true;

  # Firewall ports, and the firewall itself
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # Pins defaults for stateful data such as file locations and database versions, so leave it at the release this system was first installed from
  system.stateVersion = "25.11";

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

}
