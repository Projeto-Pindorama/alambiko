# vim: set filetype=sh :

case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

c -cd "dev/opatch-${Version}.tar.xz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/opatch-${Version}"

# Patch for musl and remove err(3)-type
# and fgetln() functions that are only
# needed for the GNU C library.
# A more elaborated fix might get into
# upstream soon.
sed >"$trash/opatch.baiacu.h" \
       '199,205d; 208,258d; 286,321d' ./baiacu.h
cat "$trash/opatch.baiacu.h" > ./baiacu.h

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
