# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};

  # TODO probably move all of these to mkThumbnailer.nix or rename file to thumbnailer.nix
  mkThumbnailer = import ./lib/mkThumbnailer.nix { inherit pkgs; };
  dds-thumbnailer = mkThumbnailer
    "dds-thumbnailer"
    "${pkgs.imagemagick}/bin/convert -thumbnail x%s %i png:%o"
    "image/x-dds;";
  webp-thumbnailer = mkThumbnailer
    "webp-thumbnailer"
    "${pkgs.libwebp}/bin/dwebp %i -scale %s %s -o %o"
    "image/x-webp;image/webp;";
  # this dont work (yet?)
  swf-thumbnailer = mkThumbnailer
    "swf-thumbnailer"
    "${pkgs.xvfb_run}/bin/xvfb-run ${pkgs.gnash}/bin/gnash -1 -r 1 --screenshot-file %o --screenshot 1 --max-advances 1 -t 1 -j %s -k %s %i"
    "application/x-shockwave-flash;application/x-shockwave-flash2-preview;application/futuresplash;image/vnd.rn-realflash;";

  webp-pixbuf-loader = pkgs.callPackage ./pkgs/webp-pixbuf-loader { };

in rec {
  nixpkgs.config = {
    # Disappoint Stallman
    allowUnfree = true;

    firefox = {
      enableAdobeFlash = lib.mkDefault false;
      enableGnomeExtensions = lib.mkDefault true;
    };
  };

  nix.trustedUsers = lib.mkDefault [ "root" "benedict" "@sudo" ];

  nix.nrBuildUsers = 128;

  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
  ];
  nix.binaryCaches = [
    "https://cache.nixos.org"
    "https://all-hies.cachix.org"
  ];

  nix.gc.automatic = false;
  nix.gc.options = "--delete-older-than 7d";

  networking = {
    hostName = lib.mkDefault "shou";
    networkmanager.enable = lib.mkDefault true;
    firewall.enable = lib.mkDefault false;
  };

  # Select internationalisation properties.
  i18n = {
    inputMethod = {
      enabled = lib.mkDefault "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        uniemoji
        mozc
        typing-booster
      ];
    };
  };

  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

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

  environment = {
    # HiDPI fixes
    variables = {
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      MOZ_USE_XINPUT2 = "1";
      QT_SCALE_FACTOR = "1.25";
    };

    gnome3.excludePackages = with pkgs.gnome3; [
      gnome-software
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget (or nix repl '<nixpkgs>' and use tab-complete)
  environment.systemPackages = with pkgs; [
    paprefs pavucontrol hexchat bat ripgrep fd
    mpv smplayer docker fish nix-index docker_compose git
    noto-fonts-emoji emojione xsel bazel gnumake imagemagick curl direnv
    stack xvfb_run jq pcre kdiff3 postgresql_10 poppler_utils xmlstarlet
    libssh2 libxml2 tree gcc binutils autoconf automake gparted
    haskellPackages.ghcid hlint gimp ghc flatpak
    # (all-hies.selection { selector = p: { inherit (p) ghc865; }; })
    gnome3.dconf-editor gnome3.gnome-tweaks p7zip zip unzip pciutils usbutils
    dds-thumbnailer webp-thumbnailer # swf-thumbnailer # doesn't work yet :(
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = lib.mkDefault true;
  # programs.gnupg.agent = { enable = lib.mkDefault true; enableSSHSupport = lib.mkDefault true; };
  programs.fish.enable = lib.mkDefault true;

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

  # Enable CUPS to print documents.
  services.printing = {
    enable = lib.mkDefault true;
    drivers = [
      pkgs.gutenprint
      pkgs.gutenprintBin
    ];
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    zeroconf = {
      publish.enable = lib.mkDefault false;
      discovery.enable = lib.mkDefault false;
    };
    tcp.anonymousClients.allowAll = lib.mkDefault false;

    # Full Pulseaudio for Bluetooth support.
    package = pkgs.pulseaudioFull;

    extraModules = [ pkgs.pulseaudio-modules-bt ];

    # This seems to fix popping audio
    # THIS breaks Bluetooth in 19.09 wtf???
    # if it's still an issue retrofit it by looking at the output
    #configFile = pkgs.runCommand "default.pa" {} ''
    #  sed 's/module-udev-detect$/module-udev-detect tsched=0/' \
    #    ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
    #'';

    # Steam games
    support32Bit = true;
  };

  hardware.opengl.driSupport32Bit = lib.mkDefault true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
  };

  services.xserver = {
    enable = true;
    layout = "us";

    libinput = {
      enable = true;
      tapping = true;
    };

    desktopManager = {
      gnome3.enable = true;
    };

    displayManager = {
      gdm = {
        enable = true;
        wayland = lib.mkDefault false;

        autoLogin = {
          # is buggy, disabled for now
          enable = lib.mkDefault false;
          user = lib.mkDefault "benedict";
        };
      };
    };

    # Enable Digimend (for Huion tablet support)
    digimend.enable = true;

    # Enable WebP support in gdk-pixbuf, used by Eye of GNOME.
    # THIS DOESNT WORK. something Absolutely Imperative is going on with pixbuf-gdk
    gdk-pixbuf.modulePackages = [ pkgs.librsvg webp-pixbuf-loader ];
  };

  # Define user accounts
  users = {
    users = {
      benedict = {
        isNormalUser = lib.mkDefault true;
        uid = lib.mkDefault 1000;
        extraGroups = [ "wheel" "docker" "networkmanager" "libvirtd" "kvm" "qemu" "input" ];
        shell = pkgs.fish;
      };
      work = {
        isNormalUser = lib.mkDefault true;
        uid = lib.mkDefault 1001;
        extraGroups = [ "wheel" "docker" "networkmanager" ];
        shell = pkgs.fish;
      };
    };
    groups = {
      sudo.gid = lib.mkDefault 707;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment? no lol
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-20.03/";

  # Satisfy Elasticsearch requirement
  boot = {
    kernel.sysctl = {
      "vm.max_map_count" = 262144;
    };
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 3;
  };

  # speedz
  boot.loader.timeout = 2;

  systemd.extraConfig = ''
    LimitNOFILE=65536
    DefaultLimitNOFILE=65536
    LimitMEMLOCK=infinity
    DefaultLimitMEMLOCK=infinity
  '';
}
