#
# TODO:
#   - second language keyboard layout
#   - language switching in Gnome (keyboard)
#   - hibernation -- DONE
#   - suspend -- DONE
#   - split into logical components (OS, hardware, ...)
#   - tablet-mode
#     - sensors
#   - latex -- DONE
#
#
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

## LaTeX...
#let tex = pkg.texlive.combine {
#  inherit (pkgs.texlive) scheme-basic
#  kvoptions calc xargs ifthen iftex pgffor xint xinttools listofitems xkeyval
#  etoolbox changepage pdfcomment eso-pic environ numprint trimclip xcolor
#  pagecolor colorspace graphicx adjustbox textpos fancyvrb flowfram rotating
#  fancyhdr pdfpages geometry;
#  #(setq org-latex-compiler "lualatex")
#  #(setq org-preview-latex-default-process 'dvisvgm)
#};
#in

{
  nix.settings.experimental-features = [ 
    "nix-command" 
    "flakes"
  ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # XXX this is the same swap partition as fedora...
  boot.resumeDevice = "/dev/disk/by-uuid/6ac0c126-f701-43a5-8576-09cc76be1409";
  #boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=0" "resume_offset=13465600" ];
  swapDevices = [ 
  #  { 
  #    device = "/var/lib/swapfile"; 
  #    size = 8*1024; 
  #  } 
    { device = "/dev/disk/by-uuid/6ac0c126-f701-43a5-8576-09cc76be1409"; } 
  ];

  # XXX move to hardware-specific-file...
  powerManagement.resumeCommands = ''
    ${pkgs.kmod}/bin/modprobe -r i2c_i801
    ${pkgs.kmod}/bin/modprobe i2c_i801
  '';

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
  environment.localBinInPath = true;

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
    htop gtop
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
    bat

    # LaTeX
    (texlive.combine {
      inherit (texlive) scheme-medium
      # missing:
      #   calc graphicx ifthen pgffor rotating trimclip xinttools 
      kvoptions xargs ifthenx iftex xint listofitems xkeyval
      etoolbox changepage pdfcomment eso-pic environ numprint xcolor
      pagecolor colorspace graphics adjustbox textpos fancyvrb flowfram
      fancyhdr pdfpages geometry 
      hardwrap catchfile 
      # doc...
      titlesec hypdoc doctools needspace xstring listings imakeidx  
      latexmk;
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
    })

    # GUI
    keepassxc
    ulauncher
    kitty
    tilix
    logseq
    # XXX this does not work on default gnome...
    #wl-gammactl
    nerdfonts
    nextcloud-client

    # dev
    gnumake

    gnome.gnome-tweaks
    gnome.dconf-editor
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.quake-mode
    gnomeExtensions.gsconnect
    gnomeExtensions.dash-to-panel
    gnomeExtensions.blur-my-shell
    gnomeExtensions.custom-accent-colors
    #gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.appindicator
    gnomeExtensions.date-menu-formatter
    gnomeExtensions.lock-keys
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.hibernate-status-button
    gnomeExtensions.caffeine
    gnomeExtensions.grand-theft-focus
    # does not seem to work...
    #gnomeExtensions.syncthing-indicator
    gnome.gedit

    vlc
    mpv

    #texlive.combined.scheme-full 
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

  # ulauncher... 
  systemd.user.services.ulauncher = {
    enable = true;
    description = "Start Ulauncher";
    script = ''
      ${pkgs.coreutils-full}/bin/sleep 2
      ${pkgs.ulauncher}/bin/ulauncher --hide-window
    '';

    documentation = [ "https://github.com/Ulauncher/Ulauncher/blob/f0905b9a9cabb342f9c29d0e9efd3ba4d0fa456e/contrib/systemd/ulauncher.service" ];
    # XXX this does not work for some reason...
    #wantedBy = [ "graphical.target" ];
    wantedBy = [ "graphical-session.target" ];
    after = [ "display-manager.service" ];
  };


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
