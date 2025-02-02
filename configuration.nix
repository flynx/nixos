#
# TODO:
#   - setdisplay gamma (gnome-gamma-tool)
#   - split into logical components (OS, hardware, ...)
#   - tablet-mode
#     - sensors
#   - home manager (???)
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

  imports = [ 
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  # intel video drivers...
  # XXX move to hardware...
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
  

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

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # prevent the console fonts from being reset on driver detect/load...
  # XXX move to hardware-specific-file...
  boot.initrd.kernelModules = [ "i915" ];

  # fix an issue with the touchpad/touchpoint not working after suspend...
  # XXX move to hardware-specific-file...
  boot.blacklistedKernelModules = [
    "i2c_i801"
  ];
  #powerManagement.resumeCommands = ''
  #  ${pkgs.kmod}/bin/modprobe -r i2c_i801
  #  ${pkgs.kmod}/bin/modprobe i2c_i801
  #'';

  # NOTE: this will be reset on loading of gpu driver, this can be fixed by preloading the 
  #       driver manually via:
  #         boot.initrd.kernelModules = [ "i915" ];
  console = {
    earlySetup = true;
    packages = with pkgs; [ 
      terminus_font 
    ];
    font = "ter-u18n";
  };

  # ThinkPad keyboard auto highlight...
  # XXX this fails...
  #services.tp-auto-kbbl = {
  #  enable = true;
  #  device = "/dev/input/event19";
  #  arguments = [
  #  ];
  #};

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
  #i18n.supportedLocales = [
  #  "en_US.UTF-8"
  #  "ru_RU.UTF-8"
  #];
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

  services.gpm.enable = true;

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };
  services.xserver.excludePackages = [ 
    pkgs.xterm 
  ];
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "gnome-remote-desktop";
  services.xrdp.openFirewall = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # set keyboard layouts and switching and othe key bindings...
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.input-sources]
    sources=[('xkb', 'us'),('xkb', 'ru')]
    per-window=true


    [org.gnome.desktop.wm.keybindings]
    switch-input-source=['<Alt>Shift_L']
    switch-input-source-backward=['<Shift>Alt_L']

    panel-run-dialog=['<Super>r']


    [org/gnome/settings-daemon/plugins/media-keys]
    custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']

    [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
    binding='<Super>v'
    command='gvim'
    name='gvim'
  '';

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

  services.colord.enable = true;

  services.flatpak.enable = true;

  # Laptop configuration...
  services.logind.lidSwitch = "lock";

  services.fwupd.enable = true;

  services.openssh.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
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
      };
    };
  };
  # group keyd keyboard with the rest of the internal HID devices letting libinput correctly
  # handle touchpad features line "disable while typing"...
  environment.etc."libinput/local-overrides.quirks".text = ''
    [keyd]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';

  services.syncthing = {
    enable = true;
    user = "f_lynx";
    configDir = "/home/f_lynx/.config/syncthing/";
    dataDir = "/home/f_lynx/Sync/";
  };

  # Tor
  # see: https://nixos.wiki/wiki/Tor
  services.tor = {
    enable = true;
    client.enable = true;

    settings = {
      UseBridges = true;

      # obfs4...
      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
      Bridge = [
        "obfs4 51.68.49.200:61511 D44D53FEBBD9BFB59726B5818CEAAC5A31DFDD24 cert=1Lc1kIQ84lYXsH3duofsZWh0Eb+xVVEmmsZP8YN8tLuFfjYghEgFfIsLmo78kXX383KMRw iat-mode=0"
        "obfs4 141.95.109.208:45280 377396B625F2A76E7DF51C1BF952EBD683EC3EA1 cert=R5X70kY6Hd4DdW8JbCsxBPMaMREIOwaqbwYGMff1NyPYUwLxnlQqzkP2fTD8uo2R7A5ROQ iat-mode=0"
      ];

      ## snowflake... (XXX fails)
      #ClientTransportPlugin = "snowflake exec ${pkgs.snowflake}/bin/snowflake-client -url https://snowflake-broker.torproject.net.global.prod.fastly.net/ -front cdn.sstatic.net -ice stun:stun.l.google.com:19302,stun:stun.voip.blackberry.com:3478,stun:stun.altar.com.pl:3478,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.sonetel.net:3478,stun:stun.stunprotocol.org:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478";
      #ClientTransportPlugin = "snowflake exec ${pkgs.snowflake}/bin/snowflake-client";
      #Bridge = [
      #  "snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA url=https://1098762253.rsc.cdn77.org/ fronts=www.cdn77.com,www.phpmyadmin.net ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.net:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn"
      #  "snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA url=https://1098762253.rsc.cdn77.org/ fronts=www.cdn77.com,www.phpmyadmin.net ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.net:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn"
      #];
    };
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.f_lynx = {
    isNormalUser = true;
    description = "Alex A. Naanou";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };
  environment.localBinInPath = true;

  environment.variables.EDITOR = "vim";


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    usbutils udiskie udisks
    exfat exfatprogs
    scrounge-ntfs

    vim-full
    #micro
    vifm mc far2l nnn 
    #ranger

    psmisc
    #tdrop
    tmux
    tree
    btop htop iotop iftop
    ncdu du-dust

    # mostly needed for debugging...
    #libinput

    tlp acpi

    gparted
    #gdisk
    testdisk
    jdupes fdupes

    wget
    tor
    syncthingtray
    #shadowsocks-rust
    #shadowsocks-v2ray-plugin
    ungoogled-chromium
    #tor-browser

    zip unzip
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
      anyfontsize cprotect ccicons 
      # XXX this seems to be missing...
      #suffix 
      lipsum 
      hardwrap catchfile 
      # photobook...
      photobook
      # doc...
      titlesec hypdoc doctools needspace xstring listings imakeidx  
      latexmk;
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
    })

    # fonts...
    nerdfonts
    terminus_font 

    # GUI
    keepassxc
    ulauncher
    kitty #ghostty
    #logseq
    # XXX this does not work on default gnome...
    wl-gammactl
    nextcloud-client

    # dev
    gitFull
    gnumake
    nodejs
    electron
    go
    python3
    #python311Packages.pygobject3
    #sbcl

    # Gnome stuff...
    gnome.gnome-tweaks
    gnome.dconf-editor
    gnome.gnome-remote-desktop
    gnomeExtensions.advanced-alttab-window-switcher
    gnomeExtensions.search-light
    gnomeExtensions.quick-settings-tweaker
    #gnomeExtensions.quake-mode
    gnomeExtensions.quake-terminal
    gnomeExtensions.gsconnect
    gnomeExtensions.dash-to-panel
    gnomeExtensions.blur-my-shell
    gnomeExtensions.unmess
    gnomeExtensions.custom-accent-colors
    #gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.appindicator
    gnomeExtensions.customize-ibus
    gnomeExtensions.date-menu-formatter
    gnomeExtensions.lock-keys
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.hibernate-status-button
    gnomeExtensions.caffeine
    gnomeExtensions.grand-theft-focus
    # XXX seems to be out of date for Gnome 46...
    gnomeExtensions.guillotine
    # XXX this seems to be missing...
    #   see: https://github.com/AstraExt/astra-monitor
    #gnomeExtensions.astra-monitor

    gnome-firmware-updater
    gedit

    # media...
    vlc mpv cmus
    yt-dlp media-downloader
    ffmpeg #ffmpegthumbnailer
    httrack

    #blender
    #krita

    #texlive.combined.scheme-full 
  ];

  programs.geary.enable = false;

  #programs.git.enable = true;
  programs.dconf.enable = true;
  programs.firefox.enable = true;

  # XXX not sure who wants electron...
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # ulauncher... 
  # XXX can't get ulauncher to be centered and focus on launch...
  #systemd.user.services.ulauncher = {
  #  enable = true;
  #  description = "Start Ulauncher";
  #  script = ''
  #    ${pkgs.coreutils-full}/bin/sleep 2
  #    ${pkgs.ulauncher}/bin/ulauncher --hide-window
  #  '';

  #  documentation = [ "https://github.com/Ulauncher/Ulauncher/blob/f0905b9a9cabb342f9c29d0e9efd3ba4d0fa456e/contrib/systemd/ulauncher.service" ];
  #  # XXX this does not work for some reason...
  #  #wantedBy = [ "graphical.target" ];
  #  wantedBy = [ "graphical-session.target" ];
  #  after = [ "display-manager.service" ];
  #};


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
