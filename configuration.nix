# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};

  hw-rev = "89c4ddb0e60e5a643ab15f68b2f4ded43134f492";
  nixos-hardware = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixos-hardware/tarball/${hw-rev}";
    sha256 = "1a0mplnj0zx33f4lm7kwg6z6iwgdkg2pxy58plkj6w59ibfl2l27";
  };

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
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hardware-personal.nix
      "${nixos-hardware}/dell/xps/13-9380"
    ];

  nixpkgs.config = {
    # Disappoint Stallman
    allowUnfree = true;

    firefox = {
      enableGoogleTalkPlugin = true;
      # enableAdobeFlash = true;
      enableGnomeExtensions = true;
    };

    chromium = {
      # enablePepperFlash = true;
    };
  };

  nix.trustedUsers = [ "root" "benedict" "@sudo" ];

  nix.nrBuildUsers = 128;

  nix.binaryCachePublicKeys = [
    "all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
  ];
  nix.binaryCaches = [
    "https://all-hies.cachix.org"
  ];

  networking = {
    hostName = "shou";
    networkmanager.enable = true;
    firewall.enable = false;
  } // (if services.dnscrypt-proxy.enable
        then { nameservers = [ "127.0.0.1" ]; }
        else {});

  services.dnscrypt-proxy = {
    enable = false;
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        uniemoji
        mozc
      ];
    };
  };

  fonts.fonts = with pkgs; [
    noto-fonts-emoji emojione carlito ipafont kochi-substitute lmodern
  ];

  # Set your time zone.
  time.timeZone = "Europe/London";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim tmux firefox spotify paprefs qbittorrent pavucontrol hexchat bat ripgrep fd
    mpv smplayer docker chrome-gnome-shell fish nix-index docker_compose git
    noto-fonts-emoji emojione xsel bazel gnumake imagemagick curl direnv
    stack xvfb_run jq pcre kdiff3 postgresql_10 poppler_utils xmlstarlet
    libssh2 libxml2 tree gcc binutils autoconf automake gparted alacritty
    rxvt_unicode haskellPackages.ghcid hlint gimp chromium wine ghc flatpak
    # (all-hies.selection { selector = p: { inherit (p) ghc865; }; })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.fish.enable = true;

  # List services that you want to enable:
  services.gnome3.chrome-gnome-shell.enable = true;
  #services.xserver.displayManager.gdm.autoLogin.user = "benedict";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.flatpak.enable = true;

  services.nginx = {
    enable = true;

    user = "benedict";
    group = "users";

    virtualHosts = {
      "localhost" = {
        default = true;
        root = "/home/benedict/Public";

        locations."/" = {
          extraConfig = ''
            autoindex on;
          '';
        };
      };
    };
  };

  # Enable Docker daemon.
  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
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
      publish.enable = true;
      discovery.enable = true;
    };
    tcp.anonymousClients.allowAll = true;

    # Full Pulseaudio for Bluetooth support.
    package = pkgs.pulseaudioFull;

    extraModules = [ pkgs.pulseaudio-modules-bt ];

    # Steam gaymes
    support32Bit = true;
  };

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  hardware.bluetooth.enable = true;

  # Enable A2DP sink.
  hardware.bluetooth.extraConfig = "
    [General]
    Enable=Source,Sink,Media,Socket
  ";

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
      job.preStart = ''
        mkdir -p /run/gdm/.config/pulse
        ln -sf ${pulseConfig} /run/gdm/.config/pulse/default.pa
        chown -R gdm:gdm /run/gdm/.config
      '';
      gdm = {
        enable = true;
        wayland = false;
      };
      lightdm = {
        enable = false;
        autoLogin = {
          enable = true;
          user = "benedict";
        };
      };
    };

  };

  # Define user accounts
  users = {
    users = {
      benedict = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "sudo" "docker" "networkmanager" ];
        shell = pkgs.fish;
      };
      work = {
        isNormalUser = true;
        uid = 1001;
        extraGroups = [ "sudo" "docker" ];
        shell = pkgs.fish;
      };
    };
    groups = {
      sudo.gid = 707;
    };
  };

  # Set up sudoers group
  security.sudo.configFile = ''%sudo ALL=(ALL) ALL'';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment? no lol
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-20.03/";

  # Satisfy Elasticsearch requirement
  boot.kernel.sysctl = {
    "vm.max_map_count" = 262144;
  };

  boot.kernelModules = [ "kvm-intel" ];

  systemd.extraConfig = ''
    LimitNOFILE=65536
    DefaultLimitNOFILE=65536
  '';
}
