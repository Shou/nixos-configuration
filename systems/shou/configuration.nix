{ pkgs, lib, ... }:

rec {
  imports = [
    # "${config}/configuration.nix"
    ../../configuration.nix
    /home/work/Prog/Habito/monorepo/nix/nixos
    ./hardware-configuration.nix
    ./hardware-personal.nix
  ];

  nixpkgs.config = {
    firefox.enableAdobleFlash = true;
    chromium.enablePepperFlash = false;
  };

  environment.systemPackages = with pkgs; [
    bind
    wineWowPackages.staging
    (winetricks.override { wine = wineWowPackages.staging; })
  ];

  networking.hosts."127.0.0.1" = [
    "localhost"
    "xn--9q8h"
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_4_19;
    # idk let's try it without patches??
    kernelPatches = lib.const [] [
      {
        name = "drm-i915-fast-narrow-link";
        patch = ./0001-drm-i915-Try-to-use-fast-narrow-link-on-eDP-again-an_5.4.x.patch;
      }
    ];
    kernelParams = [
      "libata.force=noncq"
    ];
  };
}
