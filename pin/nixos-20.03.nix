let
  config = {
    allowUnfree = true;
  };

in import (fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-20.03") {
  inherit config;
}
