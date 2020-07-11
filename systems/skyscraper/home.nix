{ pkgs, ... }:

rec {
  imports = [
    ./../../home.nix
  ];

  home.packages = with pkgs; [
    discord qbittorrent
  ];
}
