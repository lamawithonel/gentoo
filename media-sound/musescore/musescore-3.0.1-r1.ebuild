# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CMAKE_MIN_VERSION="3.11"
inherit cmake-utils xdg-utils gnome2-utils

DESCRIPTION="WYSIWYG Music Score Typesetter"
HOMEPAGE="https://musescore.org/"
# MuseScore_General-0.1.3.tar.bz2 packaged from https://ftp.osuosl.org/pub/musescore/soundfont/MuseScore_General/
# It has to be repackaged because the files are not versioned, current version can be found in VERSION file there.
SRC_URI="https://github.com/musescore/MuseScore/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://dev.gentoo.org/~fordfrog/distfiles/MuseScore_General-0.1.3.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa debug jack mp3 portaudio portmidi pulseaudio vorbis webengine"
REQUIRED_USE="portmidi? ( portaudio )"

RDEPEND="
	dev-qt/designer:5
	dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qthelp:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	>=dev-qt/qtsingleapplication-2.6.1_p20171024
	dev-qt/qtsvg:5
	dev-qt/qtxml:5
	dev-qt/qtxmlpatterns:5
	>=media-libs/freetype-2.5.2
	media-libs/libsndfile
	sys-libs/zlib:=
	alsa? ( >=media-libs/alsa-lib-1.0.0 )
	jack? ( virtual/jack )
	mp3? ( media-sound/lame )
	portaudio? ( media-libs/portaudio )
	portmidi? ( media-libs/portmidi )
	pulseaudio? ( media-sound/pulseaudio )
	vorbis? ( media-libs/libvorbis )
	webengine? ( dev-qt/qtwebengine:5[widgets] )
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${P}-man-pages.patch"
	"${FILESDIR}/${P}-porttime.patch"
)

S="${WORKDIR}/MuseScore-${PV}"

src_prepare() {
	cmake-utils_src_prepare

	# Move soundfonts to the correct directory
	mv "${WORKDIR}"/sound/* "${S}"/share/sound/ || die "Failed to move soundfont files"
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DDOWNLOAD_SOUNDFONT=OFF
		-DUSE_SYSTEM_QTSINGLEAPPLICATION=ON
		-DUSE_PATH_WITH_EXPLICIT_QT_VERSION=ON
		-DUSE_SYSTEM_FREETYPE=ON
		-DBUILD_ALSA="$(usex alsa)"
		-DBUILD_JACK="$(usex jack)"
		-DBUILD_LAME="$(usex mp3)"
		-DBUILD_PORTAUDIO="$(usex portaudio)"
		-DBUILD_PORTMIDI="$(usex portmidi)"
		-DBUILD_PULSEAUDIO="$(usex pulseaudio)"
		-DSOUNDFONT3="$(usex vorbis)"
		-DBUILD_WEBENGINE="$(usex webengine)"
	)
	cmake-utils_src_configure
}

src_compile() {
	cd "${BUILD_DIR}" || die
	cmake-utils_src_make -j1 lrelease manpages
	cmake-utils_src_compile
}

pkg_postinst() {
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
	gnome2_icon_cache_update
}
