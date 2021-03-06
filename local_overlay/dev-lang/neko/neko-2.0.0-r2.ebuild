# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit base

DESCRIPTION="Neko is a high-level dynamically typed programming language."
HOMEPAGE="http://nekovm.org/"
SRC_URI="http://nekovm.org/media/${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="amd64 ~arm ~ppc x86"
IUSE=""

DEPEND="dev-libs/boehm-gc[threads]"
RDEPEND="${DEPEND}"

MAKEOPTS+=" -j1"

src_configure() {
	# Reading things from stdin doesn't work, so just replace with "s" (i.e. skip).
	sed -i 's/readline();/"s";/' src/tools/install.neko || die "Unable to modify install.neko."
}

src_prepare() {
	epatch "${FILESDIR}/${PV}-soname.patch"

	# fix path to use lib64 for appropriate architectures
	sed -i -e "s:\/lib\/:\/$(get_libdir)\/:g" Makefile \
		|| die "patching Makefile failed"
	sed -i -e "s:\/lib$:\/$(get_libdir):" Makefile \
		|| die "patching Makefile failed"

	sed -i 's/xlocale\.h/locale.h/' libs/std/sys.c \
		|| die 'patching libs/std/sys.c failed'
}

src_install() {
	mkdir -p "${D}/usr/"{$(get_libdir),bin} # Missing from install target
	emake INSTALL_PREFIX="${D}/usr" install
}
