{ pkgs, ... }:

rec {
  imports = [
    ./../../home.nix
  ];

  programs.bash.enable = false;

  home.packages = with pkgs; [
    discord krita
  ];
}
