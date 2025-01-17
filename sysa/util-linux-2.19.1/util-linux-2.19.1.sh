# SPDX-FileCopyrightText: 2021-22 fosslinux <fosslinux@aussies.space>
#
# SPDX-License-Identifier: GPL-3.0-or-later

src_prepare() {
    default

    # We don't have gettext (autopoint) yet.
    AUTOPOINT=true AUTOMAKE=automake-1.10 ACLOCAL=aclocal-1.10 AUTOM4TE=autom4te-2.64 autoreconf-2.64 -fi
}

src_configure() {
    ./configure --prefix="${PREFIX}" \
        --bindir="${PREFIX}/bin" \
        --sbindir="${PREFIX}/bin" \
        --libdir="${PREFIX}/lib/musl" \
        --build=i386-unknown-linux-gnu \
        --disable-libuuid \
        --without-ncurses \
        --enable-static \
        --enable-static-programs=losetup,mount,umount,fdsik,sfdisk,blkid \
        --enable-shared=no \
        --disable-wall \
        ac_cv_type_loff_t=yes
}
