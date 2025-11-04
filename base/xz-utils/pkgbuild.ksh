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
		CC=clang
		CXX=clang++
		AR=llvm-ar
		RANLIB=llvm-ranlib
		export CC CXX AR RANLIB
		;;
esac

c -cd "xz-$Version.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/xz-$Version"

configure_opts=(
	"--prefix=/$PREFIX"
	"--bindir=/bin"
	"--libdir=/$PREFIX/lib"
	"--enable-year2038"
)

if ! $xtools; then
	configure_opts+=(
		"--docdir="/usr/share/doc/$(basename $(pwd))"" \
		"--disable-nls" \
		"--disable-rpath"
	)

else
	configure_opts+=(
		"--target=$COPA_TARGET" \
		"--build=$COPA_HOST"
	)
fi

./configure ${configure_opts[@]}
gmake -j$(nproc)
DESTDIR="$Destdir" gmake install
