# SPDX-FileCopyrightText: 2021-22 fosslinux <fosslinux@aussies.space>
#
# SPDX-License-Identifier: GPL-3.0-or-later

urls="http://download.nust.na/pub2/openpkg1/sources/DST/flex/flex-2.5.33.tar.gz"

src_prepare() {
    default

    AUTOPOINT=true AUTOMAKE=automake-1.15 ACLOCAL=aclocal-1.15 autoreconf-2.69 -fi

    # Remove pregenerated files
    rm parse.c parse.h scan.c 

    # Remove pregenerated .info
    rm doc/flex.info
}

src_configure() {
    ./configure \
        --prefix="${PREFIX}" \
        --libdir="${PREFIX}/lib/musl" \
        --program-suffix=-2.5.33
}

src_compile() {
    make MAKEINFO=true
}

src_install() {
    make MAKEINFO=true DESTDIR="${DESTDIR}" install
}
