{ ... }:

let
  pkgs = import ../../pin/nixos-20.03.nix;

in {
  imports = [
    ./../../home.nix
  ];

  home.packages = with pkgs; [
    discord qbittorrent
  ];
}
