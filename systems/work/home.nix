{ overrides, ... }:

let
  sources = import ./../../nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  master = import sources.master {};

in {
  imports = [
    ./../../home.nix
  ];

  home.packages = with pkgs; [
    master.zoom-us tmux-xpanes
  ];
} // overrides
