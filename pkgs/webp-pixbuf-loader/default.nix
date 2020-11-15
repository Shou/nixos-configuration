{ lib
, meson
, ninja
, stdenv
, fetchFromGitHub
, gdk-pixbuf
, pkgconfig
, libwebp
}:

stdenv.mkDerivation rec {
  pname = "webp-pixbuf-loader";
  version = "0.0.2";

  src = fetchFromGitHub {
    repo = "webp-pixbuf-loader";
    owner = "aruiz";
    rev = version;
    sha256 = "057gxb1qgldljkf8hjik8dy2zr5xvhac3sxvh1w6zzh6ch0b6hl0";
  };

  buildInputs = [
    libwebp
    gdk-pixbuf.dev
  ];

  nativeBuildInputs = [ meson ninja pkgconfig ];

  mesonFlags = [
    "-Dgdk_pixbuf_query_loaders_path=${gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders"
  ];

  installPhase = ''
    mkdir -p $out/lib/gdk-pixbuf-2.0/2.10.0/loaders
    mv libpixbufloader-webp.so $out/lib/gdk-pixbuf-2.0/2.10.0/loaders
  '';

  meta = with lib; {
    description = "WebP Image format GdkPixbuf loader";
    homepage = "https://github.com/aruiz/webp-pixbuf-loader";
    license = licenses.lgpl2;
    maintainers = with maintainers; [ shou ];
    platforms = platforms.unix;
  };
}
