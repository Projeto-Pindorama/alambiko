# vim: set filetype=sh :

case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

c -cd "gnu/gettext-${Version}.tar.xz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/gettext-${Version}"

# Fix gettext-tools/src/locating-rule.c to include
# "stdlib.h" and have a declaration of free().
sed >"$trash/GNUgettext.locating-rule.c" '/xalloc\.h/a\
#include <stdlib.h>' ./gettext-tools/src/locating-rule.c &&
	cat "$trash/GNUgettext.locating-rule.c" \
		>./gettext-tools/src/locating-rule.c

[ -e Makefile ] && gmake clean
if ! $xtools; then
	configure_opts=(
		"--prefix=/usr/ccs"
		"--enable-static"
		"--enable-shared"
		"--docdir=/usr/share/doc/gnu/$(basename $(pwd))"
	)
	export LDFLAGS
else
	configure_opts=(
		"CROSS_COMPILE=${TARGET_TUPLE}-"
		"--prefix=/"
		"--target=${TARGET_TUPLE}"
		"--disable-libasprintf"
		"--disable-curses"
		"--disable-acl"
		"--disable-java"
	)
fi

./configure ${configure_opts[@]}
gmake -j$(nproc)
if ! $xtools; then
	DESTDIR="$Destdir" gmake install
else
	mkdir -p "$Destdir/bin"
	cp gettext-tools/src/{msgfmt,msgmerge,xgettext} "$Destdir/bin"
fi
