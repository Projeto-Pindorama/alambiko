# vim: set filetype=sh :

xtools=true
case "x${Destdir##*/}" in
	'x')
		xtools=false
		PREFIX=usr
		C_FLAGS="$CFLAGS"
		;;
	*)
		PREFIX=''
		# Disable compiler optimizations
		# for the toolchain.
		C_FLAGS='-O0'
		;;
esac

c -cd "$Version.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/zlib-ng-$Version"
# Fix the configure script to use Heirloom's sed (from UNIX v7).
# Also fix grep '-q' calls, even if it's using the POSIX one.
sed -e '/grep -q/{ s@-q@2>\&1 >/dev/null@; }' \
	-e '/^replace_in_file().*$/{n; n; n; s/else/elif [ ! `getconf HEIRLOOM_TOOLCHEST_VERSION 2>\/dev\/null` \]\; then/; n; n; s/\(.*\)fi/\1else\
\1\1sed >"$2".tmp -e "$1" "$2" \&\& cat "$2".tmp > "$2" \&\& rm "$2".tmp\
\1fi/; }' configure >"$trash/configure_zlib-ng" &&
	cp "$trash/configure_zlib-ng" ./configure &&
	rm "$trash/configure_zlib-ng"

if $xtools; then
	CC=${TARGET_TUPLE}-gcc
	CXX=${TARGET_TUPLE}-g++
fi
export CC CXX

./configure --prefix=/$PREFIX \
	--libdir=/$PREFIX/lib \
	--sharedlibdir=/lib \
	--zlib-compat
gmake -j$(nproc)
CFLAGS="$C_FLAGS" DESTDIR="$Destdir" gmake install
(
	cd "$Destdir/lib"
	ln -s libz.so.?.?.?.zlib-ng libz.so.1.3.11
)
unset C_FLAGS
