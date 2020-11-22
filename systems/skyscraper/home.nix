{ ... }:

let
  sources = import ../../nix/sources.nix;
  stable = import sources.nixpkgs {};
  pkgs = import sources.unstable {};

in {
  imports = [
    ./../../home.nix
  ];

  home.packages = with pkgs; [
    discord qbittorrent steam stable.mpv youtube-dl unar krita aseprite-unfree
    etcher ffmpeg-full file pciutils usbutils cachix xdg_utils
  ];

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-timeout = 7200;
    "org/gnome/desktop/screensaver".lock-delay = 3600;
  };
}
