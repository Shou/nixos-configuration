let
  config = {
    allowUnfree = true;
  };

in import (fetchTarball "https://github.com/NixOS/nixpkgs/tarball/32b46dd897ab2143a609988a04d87452f0bbef59") {
  inherit config;
}
