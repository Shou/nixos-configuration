{ ... }:

let
  pkgs = import ../../pin/nixos-20.03.nix;
  unstable = import ../../pin/nixos-unstable.nix;

in {
  imports = [
    ./../../home.nix
  ];

  home.packages = with pkgs; [
    unstable.discord qbittorrent steam
  ];
}
