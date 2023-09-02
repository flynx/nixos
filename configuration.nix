#
# TODO:
#   - second language layout
#   - language switching in Gnome (keyboard)
#   - hibernation
#     - down works
#     - up broken
#   - suspend (broken)
#   - split into logical components (OS, hardware, ...)
#
#
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "yoga-nix";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Configure keymap in X11
  services.xserver = {
    layout = "us, ru";
    xkbVariant = "";
  };
  services.xserver.excludePackages = [ 
    pkgs.xterm 
  ];


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  #services.xserver.desktopManager.gnome = {
  #  extraGSettingsOverrides = ''
  #    sources=[('xkb', 'us, ru')]
  #  '';
  #};
  environment.gnome.excludePackages = [ 
    pkgs.gnome-tour 
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.f_lynx = {
    isNormalUser = true;
    description = "Alex A. Naanou";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim-full
    nodejs
    go
    vifm

    psmisc
    #tdrop
    tmux
    tree
    htop
    iotop
    iftop

    gparted
    #gdisk
    testdisk
    jdupes

    wget
    tor
    #syncthing

    tldr

    # GUI
    keepassxc
    ulauncher
    kitty
    tilix

    #gnomeExtensions.ddterm
    gnome.gnome-tweaks
    gnomeExtensions.quake-mode
    gnomeExtensions.gsconnect
    gnomeExtensions.dash-to-panel
    gnomeExtensions.blur-my-shell
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.date-menu-formatter
    gnomeExtensions.lock-keys
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.hibernate-status-button
    gnomeExtensions.caffeine
    gnomeExtensions.grand-theft-focus
    gnomeExtensions.syncthing-indicator
    gnome.gedit

    vlc
    mpv
  ];

  programs.geary.enable = false;

  programs.git.enable = true;
  programs.dconf.enable = true;
  programs.firefox.enable = true;


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.openssh.enable = true;

  services.syncthing.enable = true;
  services.syncthing.user = "f_lynx";
  services.syncthing.configDir = "/home/f_lynx/.config/syncthing/";
  services.syncthing.dataDir = "/home/f_lynx/Sync/";

  services.keyd.enable = true;
  services.keyd.ids = [
    "*"
  ];
  services.keyd.settings = {
    main = {
      # Modern ThinkPad's printscrn to menu key...
      sysrq = "overload(prtsc, compose)";

      rightshift = "overload(rightshift, rightshift)";
      rightalt = "overload(rightalt, rightalt)";
    };
    prtsc = {
      # Gnome: screenshot...
      rightshift = "sysrq";

      # Gnome: minimize/maximize...
      up = "M-up";
      down = "M-down";

      # Gnome: next/prev workspace...
      left = "M-A-left";
      right = "M-A-right";
    };
    "rightshift:S" = {
      # Gnome: screenshot...
      sysrq = "sysrq";
    };
    "rightalt:A" = {
      # Gnome: move window...
      left = "macro(A-f7 20ms left left enter)";
      right = "macro(A-f7 20ms right right enter)";
      up = "macro(A-f7 20ms up up enter)";
      down = "macro(A-f7 20ms down down enter)";
    };
  };

  services.flatpak.enable = true;

  # Laptop configuration...
  services.logind.lidSwitch = "lock";


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
