# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
#
# SPDX-License-Identifier: GPL-3.0-or-later

urls="https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz"

src_prepare() {
    find . -name '*.info*' -delete

    autoreconf-2.71 -fi
}

src_configure() {
    ./configure \
	--prefix="${PREFIX}" \
	--libdir="${PREFIX}/lib/musl" \
	--build=i386-unknown-linux-musl \
	--disable-shared \
	--with-gcc-arch=generic \
	--enable-pax_emutramp
}
