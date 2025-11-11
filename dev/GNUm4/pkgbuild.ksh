# vim: set filetype=sh :

case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

c -cd "gnu/autohell/m4-${Version}.tar.xz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/m4-${Version}"

[ -e Makefile ] && gmake distclean
if ! $xtools; then
	configure_opts=(
		"--prefix=/usr/ccs"
		"--enable-static"
		"--enable-shared"
		"--docdir=/usr/share/doc/gnu/$(basename $(pwd))"
	)
	export CFLAGS LDFLAGS
else
	configure_opts=(
		"--prefix=/"
		"--host=$COPA_TARGET"
		"--build=$COPA_HOST"
	)
fi

CC=clang \
CXX=clang++ \
AR=llvm-ar \
RANLIB=llvm-ranlib \
	./configure ${configure_opts[@]}
gmake -j$(nproc) && gmake DESTDIR="$Destdir" install
