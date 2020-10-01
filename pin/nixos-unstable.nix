let
  config = {
    allowUnfree = true;
  };

in import (fetchTarball "https://github.com/NixOS/nixpkgs/tarball/1937fd3f1906e2c0909e889ddd31f2e77cbd8bfc") {
  inherit config;
}
