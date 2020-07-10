# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:


rec {
  imports = [
    ./hardware-configuration.nix
    ./hardware-personal.nix
    ./../../configuration.nix
  ];

  nixpkgs.config = {
    firefox.enableAdobeFlash = true;
    chromium.enablePepperFlash = true;
  };

  networking.hostName = "skyscraper";

  environment.systemPackages = with pkgs; [
    p7zip zip unzip pciutils usbutils firefox chromium
    wineWowPackages.staging
    (winetricks.override { wine = wineWowPackages.staging; })
    # (all-hies.selection { selector = p: { inherit (p) ghc882; }; })
  ];

  users.users.andrea = {
    isNormalUser = true;
    uid = 1002;
    extraGroups = [ "networkmanager" "libvirtd" "kvm" "qemu" ];
    shell = pkgs.fish;
  };

  services.nginx.virtualHosts."localhost".root = "/home/benedict/Videos";

  ### Virtualisation
  boot.kernelModules = [
    "kvm-amd" "kvm-intel"
    # Add VFIO kernel modules
    "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio"
  ];
  # Enable IOMMU
  boot.kernelParams = [ "amd_iommu=on" ];
  boot.kernelPackages = pkgs.linuxPackages_4_19;
  # Blacklist GPU drivers
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];

  # Attach GPU to VFIO driver
  boot.extraModprobeConfig = "options vfio-pci ids=10de:1c03,10de:10f1";

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
