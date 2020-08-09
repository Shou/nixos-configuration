{ ... }:

let
  pkgs = import ../../pin/nixos-20.03.nix;
  unstable = import ../../pin/nixos-unstable.nix;

in {
  imports = [
    ./../../home.nix
  ];

  programs.bash.enable = false;

  home.packages = with pkgs; [
    unstable.discord krita steam
  ];
}
