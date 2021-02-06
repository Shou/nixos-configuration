{ pkgs, lib, ... }:

let
  sources = import ../../nix/sources.nix;
  # Maybe we _should_ consider using this one?
  # pkgs = import sources.nixpkgs {};
  unstable = import sources.nixos-unstable {};

in {
  imports = [
    # "${config}/configuration.nix"
    ../../configuration.nix
    # TODO move out from here and use a fetcher so we can hash it
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

  services.synergy.client = {
    enable = false;
    screenName = "shou";
    serverAddress = "10.0.0.13";
  };

  # Buttery savings
  powerManagement.powertop.enable = true;

  boot = {
    # kernelPackages = pkgs.linuxPackages_4_19;
    kernelPackages = unstable.linuxPackages_5_7;
    # idk let's try it without patches?? (this only applies to 5.2+ kernels)
    kernelPatches = lib.const [] [
      {
        name = "drm-i915-fast-narrow-link";
        patch = ./0001-drm-i915-Try-to-use-fast-narrow-link-on-eDP-again-an_5.4.x.patch;
      }
    ];
    kernelParams = [
      "libata.force=noncq"
      "i915.enable_psr=0"
      "i915.enable_dc=-1"
      "i915.enable_fbc=0"
      "i915.fastboot=1"
      "i915.edp_vswing=2"
    ];
  };
}
