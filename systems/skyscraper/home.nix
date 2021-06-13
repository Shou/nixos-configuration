{ ... }:

let
  sources = import ../../nix/sources.nix;
  stable = import sources.nixpkgs {};
  pkgs = import sources.unstable {};
  master = import sources.master {};

in {
  imports = [
    ./../../home.nix
  ];

  home.packages = with pkgs; [
    master.discord qbittorrent steam stable.mpv master.youtube-dl unar master.krita master.aseprite-unfree
    etcher ffmpeg-full file pciutils usbutils cachix xdg_utils
  ];

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-timeout = 7200;
    "org/gnome/desktop/screensaver".lock-delay = 3600;
  };

  home.file."mpv-config" = {
    source = ../../config/mpv/mpv.conf;
    target = ".config/mpv/mpv.conf";
  };
}
