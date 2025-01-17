# SPDX-FileCopyrightText: 2021 fosslinux <fosslinux@aussies.space>
#
# SPDX-License-Identifier: GPL-3.0-or-later

urls="http://deb.debian.org/debian/pool/main/d/dist/dist_3.5-236.orig.tar.gz"

# We manually compile here because ./Configure uses metaconfig itself
# *sigh*

src_prepare() {
    default

    sed 's/@PERLVER@/5.10.1/' config.sh.in > config.sh
}

src_compile() {
    cd mcon
    ./mconfig.SH
    perl ../bin/perload -o mconfig > metaconfig
    cd ..

    cd kit
    ./manifake.SH
    cd ..
}

src_install() {
    install mcon/metaconfig "${PREFIX}/bin/"
    install kit/manifake "${PREFIX}/bin/"
    cp -r mcon/U/ "${PREFIX}/lib/perl5/5.10.1/"
}
