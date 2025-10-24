# vim: set filetype=sh :

case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

c -cd "dev/flex-${Version}.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/flex-${Version}"

[ -e Makefile ] && gmake distclean

case "$stage" in
	second) (
		CC=clang CXX=clang++ \
		AR=llvm-ar \
		AS=llvm-as \
		RANLIB=llvm-ranlib \
		LD=ld.lld \
		STRIP=llvm-strip \
		./configure --prefix='/' \
			--build=$TARGET_TUPLE \
			--host=$TARGET_TUPLE
	) ;;
	final) (
		./configure --prefix='/usr/ccs' \
			--docdir=/usr/ccs/share/doc/$(basename "$(pwd)")
	) ;;
esac
gmake -j$(nproc) && DESTDIR="$Destdir" gmake install

(
	cd "$Destdir"
	if [[ $stage == 'final' ]]; then
		cd usr/ccs
	fi
	cd bin
	ln flex lex
)
