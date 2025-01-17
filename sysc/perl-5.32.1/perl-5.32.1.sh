# SPDX-FileCopyrightText: 2022 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2022 fosslinux <fosslinux@aussies.space>
#
# SPDX-License-Identifier: GPL-3.0-or-later

urls="http://www.cpan.org/src/5.0/perl-5.32.1.tar.xz
  http://deb.debian.org/debian/pool/main/p/perl/perl_5.32.1.orig-regen-configure.tar.gz"

src_prepare() {
    default

    # Regenerate bison files
    # perly.c looks suspiciously like it is from bison, but is not; from the
    # below script:
    # Note that perly.c is *not* regenerated - this is now a static file which
    # is not dependent on perly.y any more.
    perl regen_perly.pl

    # Regenerate other prebuilt header files
    # Taken from headers of regen scripts
    rm -f embed.h embedvar.h perlapi.c perlapi.h proto.h mg_names.inc mg_raw.h \
          mg_vtable.h opcode.h opnames.h pp_proto.h \
          lib/B/Op_private.pm overload.h overload.inc lib/overload/numbers.pm \
          reentr.h reentr.c regnodes.h lib/warnings.pm \
          warnings.h lib/feature.pm feature.h
    perl regen.pl

    # Regenerate configure + config_h.SH
    rm -f Configure config_h.SH
    ln -s ../metaconfig-5.32.1\~rc1/.package .
    ln -s ../metaconfig-5.32.1\~rc1/U .
    metaconfig -m
}

src_configure() {
    ./Configure -des \
        -Dprefix="${PREFIX}" \
        -Dcc=gcc \
        -Dusedl=false \
        -Ddate=':' \
        -Dccflags="-U__DATE__ -U__TIME__" \
        -Darchname="i386-linux" \
        -Dmyhostname="(none)" \
        -Dmaildomain="(none)"
}

src_install() {
    # Remove old perl
    rm -rf "${PREFIX}"/lib/perl5/

    default

    # Remove messed up manpages
    rm "${DESTDIR}/"*.0
    rm "${DESTDIR}${PREFIX}/lib/perl5/5.32.1/pod/perldebguts.pod"
}
