let
  config = {
    allowUnfree = true;
  };

# we really should pin this to a revision
in import (fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-20.03") {
  inherit config;
}
