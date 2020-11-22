# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  sources = import ../../nix/sources.nix;
  master = import sources.master {};

  kill-bluez = import ../../pkgs/kill-bluez { inherit pkgs; };

in {
  imports = [
    ./hardware-configuration.nix
    ./../../configuration.nix
  ];

  nixpkgs.config = {
    firefox.enableAdobeFlash = true;
  };

  networking.hostName = "skyscraper";

  environment.systemPackages = with pkgs; [
    p7zip zip unzip pciutils usbutils
    wineWowPackages.staging
    (winetricks.override { wine = wineWowPackages.staging; })
    # (all-hies.selection { selector = p: { inherit (p) ghc882; }; })
    kill-bluez
  ];

  users.users.andrea = {
    isNormalUser = true;
    uid = 1002;
    extraGroups = [ "networkmanager" "libvirtd" "kvm" "qemu" ];
    shell = pkgs.fish;
  };

  services.nginx.virtualHosts."localhost".root = "/home/benedict/Videos";

  services.synergy.server = {
    enable = false;
    screenName = "skyscraper";
  };

  security.sudo.extraRules = [
    {
      users = [ "benedict" ];
      groups = [];
      commands = [
        {
          command = "${kill-bluez}/bin/kill-bluez";
          options = [ "SETENV" "NOPASSWD" ];
        }
      ];
    }
  ];

  boot = {
  ### Virtualisation
    kernelModules = [
      "kvm-amd" "kvm-intel"
      # Add VFIO kernel modules
      "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio"
    ];
    # Enable IOMMU
    kernelParams = [ "amd_iommu=on" ];
    kernelPackages = master.linuxPackages_5_9;
    # Blacklist GPU drivers
    blacklistedKernelModules = [ "nvidia" "nouveau" ];

    # We're using LUKS on LVM so wait for scan
    initrd.luks.devices.nixos.preLVM = false;
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Attach GPU to VFIO driver
    extraModprobeConfig = "options vfio-pci ids=10de:1c03,10de:10f1";
  };

  hardware.cpu.amd.updateMicrocode = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"
    SUBSYSTEM=="usb", ATTR{idVendor}=="10de", ATTR{idProduct}=="1c03" OWNER="root", GROUP="kvm"
    SUBSYSTEM=="usb", ATTR{idVendor}=="10de", ATTR{idProduct}=="10f1" OWNER="root", GROUP="kvm"
    ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c53f", MODE="660", OWNER="root", GROUP="kvm"
    ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8009", MODE="660", OWNER="root", GROUP="kvm"
    ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="2011", MODE="660", OWNER="root", GROUP="kvm"
  '';
}
