# SPDX-FileCopyrightText: 2022 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>
#
# SPDX-License-Identifier: GPL-3.0-or-later

src_prepare() {
    default

    rm doc/amhello-1.0.tar.gz doc/automake.info*

    sed -i 's/autoreconf/autoreconf-2.61/' doc/Makefile.am
    AUTOM4TE=autom4te-2.61 AUTOCONF=autoconf-2.61 AUTOHEADER=autoheader-2.61 AUTORECONF=autoreconf-2.61 ./bootstrap
}

src_configure() {
    AUTORECONF=autoreconf-2.61 AUTOHEADER=autoheader-2.61 AUTOCONF=autoconf-2.61 AUTOM4TE=autom4te-2.61 ./configure CC=tcc --prefix="${PREFIX}"
}

src_compile() {
    AUTOM4TE=autom4te-2.61 make MAKEINFO=true CC=tcc
}

src_install() {
    make install MAKEINFO=true DESTDIR="${DESTDIR}"
    rm "${DESTDIR}${PREFIX}/share/doc/automake/amhello-1.0.tar.gz"
    rm "${DESTDIR}/usr/bin/automake" "${DESTDIR}/usr/bin/aclocal"

    # Delete some stray directories
    rm -r "${DESTDIR}${SOURCES}"
}
