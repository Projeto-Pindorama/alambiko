# vim: set filetype=sh :

case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

c -cd "dev/opatch-${Version}.tar.xz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/opatch-${Version}"

gmake clean
case "$stage" in
	second) _CFLAGS='-O0' ;;
	final) _CFLAGS="$CFLAGS" ;;
esac
gmake CFLAGS="$_CFLAGS" -j$(nproc) &&
	case "$stage" in
		second)
			gmake ROOT="$Destdir" \
				CCSBIN=/bin \
				CCSMAN=/share/man \
				install
			;;
		final)
			gmake ROOT="$Destdir" install
			;;
	esac
unset _CFLAGS
