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

c -cd "xz-$Version.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/xz-$Version"

configure_opts=(
	"--prefix=/$PREFIX"
	"--bindir=/bin"
	"--libdir=/$PREFIX/lib"
	"--sharedlibdir=/lib"
	"--enable-year2038"
)

if ! $xtools; then
	set -A configure_opts "${configure_opts[@]}" \
		"--docdir="/usr/share/doc/$(basename $(pwd))"" \
		"--disable-nls" \
		"--disable-rpath"

else
	set -A configure_opts "${configure_opts[@]}" \
		"--target=$COPA_TARGET" \
		"--build=$COPA_HOST"
fi

./configure ${configure_opts[@]}
gmake -j$(nproc)
DESTDIR="$Destdir" gmake install
