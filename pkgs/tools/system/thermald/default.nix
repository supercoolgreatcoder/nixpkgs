{ stdenv, fetchFromGitHub, autoconf, automake, libtool, pkgconfig, dbus_libs, dbus_glib, libxml2 }:

stdenv.mkDerivation rec {
  name = "thermald-${version}";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "01org";
    repo = "thermal_daemon";
    rev = "v${version}";
    sha256 = "0k10sl262d9slrln1vkgsxlr1pnfxzd3ycs552bl7ynf0zxpl48h";
  };

  buildInputs = [ autoconf automake libtool pkgconfig dbus_libs dbus_glib libxml2 ];

  patchPhase = ''sed -e 's/upstartconfdir = \/etc\/init/upstartconfdir = $(out)\/etc\/init/' -i data/Makefile.am'';

  preConfigure = ''
                   export PKG_CONFIG_PATH="${dbus_libs.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
                   ./autogen.sh #--prefix="$out"
                 '';

  configureFlags = [
    "--sysconfdir=$(out)/etc" "--localstatedir=/var"
    "--with-dbus-sys-dir=$(out)/etc/dbus-1/system.d"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
    ];

  preInstall = "sysconfdir=$out/etc";


  meta = with stdenv.lib; {
    description = "Thermal Daemon";
    homepage = "https://01.org/linux-thermal-daemon";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar ];
  };
}
