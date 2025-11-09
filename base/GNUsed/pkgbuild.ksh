# vim: set filetype=sh :

case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

c -cd "gnu/sed-${Version}.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/sed-${Version}"

[ -e Makefile ] && gmake distclean
if ! $xtools; then
	configure_opts=(
		"--prefix=/usr/gnu"
	)
	export CFLAGS LDFLAGS
else
	configure_opts=(
		"--prefix=/"
	)
fi

./configure ${configure_opts[@]}
gmake -j$(nproc) && gmake DESTDIR="$Destdir" install
