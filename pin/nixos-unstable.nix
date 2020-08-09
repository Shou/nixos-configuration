let
  config = {
    allowUnfree = true;
  };

in import (fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable") {
  inherit config;
}
