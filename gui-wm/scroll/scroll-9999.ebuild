# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit fcaps meson optfeature

DESCRIPTION="i3-compatible Wayland compositor (sway fork) with a scrolling layout and Lua scripting"
HOMEPAGE="https://github.com/dawsers/scroll"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/dawsers/${PN}.git"
else
	SRC_URI="https://github.com/dawsers/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+libinput +drm +session +scrollbar +scrollnag tray wallpapers x11-backend X"
REQUIRED_USE="tray? ( scrollbar )"

DEPEND="
	>=dev-libs/json-c-0.13:0=
	>=dev-libs/libinput-1.26.0:0=
	virtual/libudev
	sys-auth/seatd:=
	dev-libs/libevdev
	dev-libs/libpcre2
	>=dev-libs/wayland-1.21.0
	dev-lang/lua:5.4
	x11-libs/cairo
	x11-libs/libdrm
	>=x11-libs/libxkbcommon-1.5.0:0=
	x11-libs/pango
	x11-libs/pixman
	media-libs/libglvnd
	scrollbar? ( x11-libs/gdk-pixbuf:2 )
	tray? ( || (
		sys-apps/systemd
		sys-auth/elogind
		sys-libs/basu
	) )
	wallpapers? ( gui-apps/swaybg[gdk-pixbuf(+)] )
	X? (
		x11-libs/libxcb:0=
		x11-libs/xcb-util-wm
	)
	gui-libs/wlroots:0.21[drm=,libinput=,session=,X=,x11-backend=]
"
RDEPEND="
	${DEPEND}
	x11-misc/xkeyboard-config
"
BDEPEND="
	>=dev-libs/wayland-protocols-1.48
	>=dev-build/meson-1.3
	>=app-text/scdoc-1.9.2
	virtual/pkgconfig
"

FILECAPS=(
	cap_sys_nice usr/bin/${PN}
)

src_prepare() {
	default

	# Gentoo ships lua as a slotted lua5.4.pc; lua.pc only exists if
	# eselect-lua has selected it.
	sed -i "s/dependency('lua', /dependency(['lua5.4', 'lua-5.4', 'lua'], /" meson.build || die
	grep -q "'lua5.4'" meson.build || die "lua dependency patch did not apply"
}

src_configure() {
	local emesonargs=(
		-Dman-pages=enabled
		$(meson_feature tray)
		$(meson_feature scrollbar gdk-pixbuf)
		$(meson_use scrollnag)
		$(meson_use scrollbar)
		$(meson_use wallpapers default-wallpaper)
		-Dfish-completions=true
		-Dzsh-completions=true
		-Dbash-completions=true
	)

	meson_src_configure
}

pkg_postinst() {
	fcaps_pkg_postinst

	optfeature_header "There are several packages that may be useful with scroll:"
	optfeature "wallpaper utility" gui-apps/swaybg
	optfeature "idle management utility" gui-apps/swayidle
	optfeature "simple screen locker" gui-apps/swaylock
	optfeature "lightweight notification daemon" gui-apps/mako
}
