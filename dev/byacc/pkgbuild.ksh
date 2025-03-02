# vim: set filetype=sh :

case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

c -cd "dev/byacc-${Version}.tgz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/byacc-${Version}"

[ -e makefile ] && gmake distclean

case "$stage" in
	second) (
		./configure --prefix='/' \
			--build=$TARGET_TUPLE \
			--host=$TARGET_TUPLE
	) ;;
	final) (
		./configure --prefix='/usr/ccs' \
			--program-prefix='b'
	) ;;
esac

gmake -j$(nproc) && DESTDIR="$Destdir" gmake install

case "$stage" in
	final) (
		cd "$Destdir/usr/ccs/bin" &&
			ln yacc /usr/ccs/bin/byacc
	) ;;
esac
