# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};

  nixos-hardware = import ./nixos-hardware.nix;

  pulseConfig = pkgs.writeText "default.pa" ''
    load-module module-device-restore
    load-module module-card-restore
    load-module module-udev-detect
    load-module module-native-protocol-unix
    load-module module-default-device-restore
    load-module module-rescue-streams
    load-module module-always-sink
    load-module module-intended-roles
    load-module module-suspend-on-idle
    load-module module-position-event-sounds
  '';

in rec {
  nixpkgs.config = {
    # Disappoint Stallman
    allowUnfree = lib.mkDefault true;

    firefox = {
      enableGoogleTalkPlugin = lib.mkDefault true;
      enableAdobeFlash = lib.mkDefault false;
      enableGnomeExtensions = lib.mkDefault true;
    };

    chromium = {
      enablePepperFlash = lib.mkDefault false;
    };
  };

  nix.trustedUsers = lib.mkDefault [ "root" "benedict" "@sudo" ];

  nix.nrBuildUsers = lib.mkDefault 128;

  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
  ];
  nix.binaryCaches = [
    "https://cache.nixos.org"
    "https://all-hies.cachix.org"
  ];

  networking = {
    hostName = lib.mkDefault "shou";
    networkmanager.enable = lib.mkDefault true;
    firewall.enable = lib.mkDefault false;
  } // (if services.dnscrypt-proxy.enable
        then { nameservers = [ "127.0.0.1" ]; }
        else {});

  services.dnscrypt-proxy = {
    enable = lib.mkDefault false;
  };

  # Configure network proxy if necessary
  # networking.proxy.default = lib.mkDefault "http://user:password@proxy:port/";
  # networking.proxy.noProxy = lib.mkDefault "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  #   consoleKeyMap = lib.mkDefault "us";
  #   defaultLocale = lib.mkDefault "en_US.UTF-8";
    inputMethod = {
      enabled = lib.mkDefault "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        uniemoji
        mozc
      ];
    };
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    emojione
    lmodern
    carlito
    ipafont
    kochi-substitute
  ];

  # Set your time zone.
  time.timeZone = lib.mkDefault "Europe/London";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    tmux spotify paprefs pavucontrol hexchat bat ripgrep fd
    mpv smplayer docker chrome-gnome-shell fish nix-index docker_compose git
    noto-fonts-emoji emojione xsel bazel gnumake imagemagick curl direnv
    stack xvfb_run jq pcre kdiff3 postgresql_10 poppler_utils xmlstarlet
    libssh2 libxml2 tree gcc binutils autoconf automake gparted alacritty
    haskellPackages.ghcid hlint gimp chromium ghc flatpak
    # (all-hies.selection { selector = p: { inherit (p) ghc865; }; })
    google-chrome gnome3.dconf-editor
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = lib.mkDefault true;
  # programs.gnupg.agent = { enable = lib.mkDefault true; enableSSHSupport = lib.mkDefault true; };
  programs.fish.enable = lib.mkDefault true;

  # List services that you want to enable:
  services.gnome3.chrome-gnome-shell.enable = lib.mkDefault true;
  #services.xserver.displayManager.gdm.autoLogin.user = lib.mkDefault "benedict";

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = lib.mkDefault true;
    forwardX11 = lib.mkDefault true;
    passwordAuthentication = lib.mkDefault false;
    permitRootLogin = lib.mkDefault "no";
    ports = lib.mkDefault [ 22 443 ];
  };

  services.flatpak.enable = lib.mkDefault true;

  services.nginx = {
    enable = lib.mkDefault true;

    user = lib.mkDefault "benedict";
    group = lib.mkDefault "users";

    virtualHosts = {
      "localhost" = {
        default = lib.mkDefault true;
        root = lib.mkDefault "/home/benedict/Public";

        locations."/" = {
          extraConfig = lib.mkDefault ''
            autoindex on;
          '';
        };
      };
    };
  };

  # Enable Docker daemon.
  virtualisation.docker.enable = lib.mkDefault true;
  virtualisation.virtualbox.host.enable = lib.mkDefault false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  # Enable CUPS to print documents.
  services.printing = {
    enable = lib.mkDefault true;
    drivers = [
      pkgs.gutenprint
      pkgs.gutenprintBin
    ];
  };

  # Enable sound.
  sound.enable = lib.mkDefault true;
  hardware.pulseaudio = {
    enable = lib.mkDefault true;
    zeroconf = {
      publish.enable = lib.mkDefault false;
      discovery.enable = lib.mkDefault false;
    };
    tcp.anonymousClients.allowAll = lib.mkDefault false;

    # Full Pulseaudio for Bluetooth support.
    package = lib.mkDefault pkgs.pulseaudioFull;

    extraModules = [ pkgs.pulseaudio-modules-bt ];

    # This seems to fix popping audio
    configFile = lib.mkDefault (pkgs.runCommand "default.pa" {} ''
      sed 's/module-udev-detect$/module-udev-detect tsched=0/' \
        ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
    '');

    # Steam games
    support32Bit = lib.mkDefault true;
  };

  hardware.opengl.driSupport32Bit = lib.mkDefault true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  hardware.bluetooth.enable = lib.mkDefault true;

  # Enable A2DP sink.
  hardware.bluetooth.extraConfig = lib.mkDefault "
    [General]
    Enable=Source,Sink,Media,Socket
  ";

  services.xserver = {
    enable = lib.mkDefault true;
    layout = lib.mkDefault "us";
    libinput = {
      enable = lib.mkDefault true;
      tapping = lib.mkDefault true;
    };
    desktopManager = {
      gnome3.enable = lib.mkDefault true;
    };
    displayManager = {
      job.preStart = lib.mkDefault (pkgs.lib.optionalString config.hardware.pulseaudio.enable ''
        mkdir -p /run/gdm/.config/pulse
        ln -sf ${pulseConfig} /run/gdm/.config/pulse/default.pa
        chown -R gdm:gdm /run/gdm/.config
      '');
      gdm = {
        enable = lib.mkDefault true;
        wayland = lib.mkDefault false;

        autoLogin = {
          # is buggy, disabled for now
          enable = lib.mkDefault false;
          user = lib.mkDefault "benedict";
        };
      };
    };
  };

  # Define user accounts
  users = {
    users = {
      benedict = {
        isNormalUser = lib.mkDefault true;
        uid = lib.mkDefault 1000;
        extraGroups = [ "sudo" "docker" "networkmanager" "libvirtd" "kvm" "qemu" ];
        shell = lib.mkDefault pkgs.fish;
      };
      work = {
        isNormalUser = lib.mkDefault true;
        uid = lib.mkDefault 1001;
        extraGroups = [ "sudo" "docker" ];
        shell = lib.mkDefault pkgs.fish;
      };
    };
    groups = {
      sudo.gid = lib.mkDefault 707;
    };
  };

  # Set up sudoers group
  security.sudo.configFile = lib.mkDefault ''%sudo ALL=(ALL) ALL'';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = lib.mkDefault "19.09"; # Did you read the comment? no lol
  system.autoUpgrade.channel = lib.mkDefault "https://nixos.org/channels/nixos-20.03/";

  # Satisfy Elasticsearch requirement
  boot.kernel.sysctl = {
    "vm.max_map_count" = lib.mkDefault 262144;
  };

  ### Virtualisation

  # Attach GPU to VFIO driver -- this is for a GTX 1060
  boot.extraModprobeConfig = lib.mkDefault "options vfio-pci ids=10de:1c03,10de:10f1";

  systemd.extraConfig = lib.mkDefault ''
    LimitNOFILE=65536
    DefaultLimitNOFILE=65536
    LimitMEMLOCK=infinity
    DefaultLimitMEMLOCK=infinity
  '';
}
