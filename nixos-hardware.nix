let
  hw-rev = "89c4ddb0e60e5a643ab15f68b2f4ded43134f492";

in builtins.fetchTarball {
  url = "https://github.com/NixOS/nixos-hardware/tarball/${hw-rev}";
  sha256 = "1a0mplnj0zx33f4lm7kwg6z6iwgdkg2pxy58plkj6w59ibfl2l27";
}
