# vim: set filetype=sh :
xtools=true
case "x${Destdir##*/}" in
	'x') xtools=false ;;
	*) break ;;
esac

c -cd "libarchive-$Version.tar.xz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/libarchive-$Version"

# Clean the source code tree.
[ -e Makefile ] && gmake -j$(nproc) distclean

if $xtools; then
CC=clang \
CXX=clang++ \
AR=llvm-ar \
AS=llvm-as \
RANLIB=llvm-ranlib \
LD=ld.lld \
STRIP=llvm-strip \
./configure --build=${TARGET_TUPLE} \
            --host=${TARGET_TUPLE} \
            --prefix=/llvmtools \
PKG_CONFIG_PATH=/llvmtools/lib/pkgconfig \
            --disable-static \
            --without-xml2 \
            --without-nettle
fi

gmake -j$(nproc) \
	&& gmake DESTDIR="${Destdir%/*}" install
