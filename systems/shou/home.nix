{ ... }:

let
  sources = import ../../nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  unstable = import sources.unstable {};

in {
  imports = [
    ./../../home.nix
  ];

  programs.bash.enable = false;

  home.packages = with pkgs; [
    unstable.discord krita steam
  ];
}
