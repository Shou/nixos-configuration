# Manually modified hardware config. This may be ignored if you aren't
# following the outlined guide and instead just want the configuration.nix.

{ config, lib, pkgs, ... }:

{
  # We're using LUKS on LVM so wait for scan
  boot.initrd.luks.devices.root.preLVM = false;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    device = "nodev";
  };

}
