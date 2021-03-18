# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
#
# SPDX-License-Identifier: GPL-3.0-or-later

src_prepare() {
    sed -i '/Makefile/d' configure.in

    rm configure Makefile.in */Makefile.in */*/Makefile.in aclocal.m4
    aclocal-1.6
    autoconf-2.52
}

src_configure() {
    ./configure --prefix=/after
}

src_compile() {
    cp m4/amversion.in m4/amversion.m4
    sed -i 's/@VERSION@/1.6.3/' m4/amversion.m4
    sed -i 's/@APIVERSION@/1.6/' m4/amversion.m4
}

src_install() {
    install automake "${PREFIX}"/bin/automake-1.6
    mkdir -p "${PREFIX}"/share/automake-1.6/am
    cp lib/Automake/*.pm "${PREFIX}"/share/automake-1.6/Automake/
    cp -r lib/am/*.am "${PREFIX}"/share/automake-1.6/am/

    install aclocal "${PREFIX}"/bin/aclocal-1.6
    cp -r m4/*.m4 "${PREFIX}"/share/aclocal-1.6/
}