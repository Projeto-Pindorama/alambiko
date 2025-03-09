# vim: set filetype=sh :
xtools=true
case "x${Destdir##*/}" in
	'x') xtools=false ;;
	*) break ;;
esac

c -cd "ksh-$Version.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/ksh-$Version"

if xtools; then
	CC=${TARGET_TUPLE}-clang
	CXX=${TARGET_TUPLE}-clang++
	AR=llvm-ar
	RANLIB=llvm-ranlib
fi
export CC CXX AR RANLIB

./bin/package make
mkdir -p "$Destdir/bin"
install -m755 "arch/$(bin/package host type)/bin/ksh" "$Destdir/bin"
if ! xtools; then
	./bin/package install "$Destdir"
	(
	cd "$Destdir"
	# Place include and share inside /usr again.
	mkdir ./usr
	mv ./share ./include ./usr
	(cd ./usr
	mkdir -p ./share/lib
	(
	# Move ksh93's 'fun' snippets to /usr/share/lib.
	cd ./share
	mv ./fun ./lib
	)
)
fi
