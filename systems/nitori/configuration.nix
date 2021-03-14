{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./valheim-server.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "nitori";

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    wget neovim nix-index
  ];

  # Unfree package whitelist
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "minecraft-server"
  ];

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    forwardX11 = true;
    passwordAuthentication = false;
    ports = [2043];
    openFirewall = true;
  };

  services.minecraft-server = {
    enable = false;
    eula = true;
    openFirewall = true;

    package = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
      version = "20w46a";
      src = builtins.fetchurl {
        url = "https://launcher.mojang.com/v1/objects/373675677cc57b9294a187a4d0ecab6f340d4189/server.jar";
        sha256 = "0r5pzy8dkx9vr114spjjbqlkhkzcd6zz49g1sxxb6hh43bb2hqyn";
      };
    });
  };

  networking.firewall.enable = true;

  users.users.nitori = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "20.09";
}
