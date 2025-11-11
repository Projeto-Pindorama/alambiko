# vim: set filetype=sh :

case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

c -cd "gnu/make-${Version}.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/make-${Version}"

[ -e Makefile ] && gmake distclean
if ! $xtools; then
	configure_opts=(
		"--prefix=/usr/ccs"
		"--infodir=/usr/ccs/share/info"
		"--mandir=/usr/ccs/share/man"
		"--docdir=/usr/share/doc/gnu/$(basename $(pwd))"
		"--program-prefix=g"
		"--enable-static"
		"--enable-shared"
		"--disable-nls"
	)
	export CFLAGS LDFLAGS
else
	configure_opts=(
		"--prefix=/"
		"--program-prefix=g"
		"--without-guile"
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
(
	cd "$Destdir"
	if ! $xtools; then
		cd ./usr/ccs/bin
	else
		cd ./bin
	fi
	ln {g,}make
	if ! $xtools; then
		cd ./usr/ccs/share/man/man1
		ln {g,}make.1
	fi
)
