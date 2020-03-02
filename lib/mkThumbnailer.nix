
{ pkgs }:

pname: exec: mimeType: pkgs.stdenv.mkDerivation rec {
  inherit pname;
  version = "0.1";

  src = null;

  unpackPhase = "echo";

  doBuild = false;

  installPhase = ''
    mkdir -p $out/share/thumbnailers
    cat <<-EOF > $out/share/thumbnailers/${pname}.thumbnailer
    [Thumbnailer Entry]
    Exec=${exec}
    MimeType=${mimeType}
    EOF
  '';

  nativeBuildInputs = with pkgs; [ wrapGAppsHook ];
}
