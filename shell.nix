{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.stdenv.lib
, mkShell ? pkgs.mkShell
}:

let
  foo = null;

in mkShell rec {
  buildInputs = (with pkgs; [
    niv
  ]);
}
