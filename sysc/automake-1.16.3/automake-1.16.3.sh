# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
#
# SPDX-License-Identifier: GPL-3.0-or-later

urls="https://mirrors.kernel.org/gnu/automake/automake-1.16.3.tar.xz"

src_prepare() {
    AUTOMAKE=automake-1.15 ACLOCAL=aclocal-1.15 AUTOCONF=autoconf-2.69 AUTOM4TE=autom4te-2.69 ./bootstrap

    rm doc/automake-history.info doc/automake.info*

    cp "${PREFIX}/bin/help2man" doc/
}

src_configure() {
    AUTOCONF=autoconf-2.69 ./configure --prefix="${PREFIX}"
}

src_compile() {
    make MAKEINFO=true
}

src_install() {
    make install MAKEINFO=true DESTDIR="${DESTDIR}"
}
