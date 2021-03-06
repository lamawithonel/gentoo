# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} )

inherit distutils-r1 eapi7-ver

DESCRIPTION="Python bindings for libgit2"
HOMEPAGE="https://github.com/libgit2/pygit2 https://pypi.org/project/pygit2/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	=dev-libs/libgit2-$(ver_cut 1-2)*
	>=dev-python/cffi-1.0:=[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	dev-python/pytest[${PYTHON_USEDEP}]"

python_prepare_all() {
	sed -i -e '/pycparser/s:<2.18::' setup.py || die
	distutils-r1_python_prepare_all
}

python_test() {
	pytest -vv --import-mode=append test || die
}
