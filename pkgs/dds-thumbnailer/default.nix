{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "dds-thumbnailer";
  version = "0.1";

  src = null;

  unpackPhase = "echo";

  doBuild = false;

  installPhase = ''
    mkdir -p $out/share/thumbnailers
    cat <<-EOF > $out/share/thumbnailers/dds.thumbnailer
    [Thumbnailer Entry]
    TryExec=${pkgs.imagemagick}/bin/convert
    Exec=${pkgs.imagemagick}/bin/convert -thumbnail x%s %i png:%o
    MimeType=image/x-dds;
    EOF
  '';

  nativeBuildInputs = with pkgs; [ wrapGAppsHook ];

  meta = with pkgs.stdenv.lib; {
    maintainers = with maintainers; [ shou ];
  };
}
