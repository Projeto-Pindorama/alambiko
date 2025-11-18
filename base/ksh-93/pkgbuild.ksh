# vim: set filetype=sh :
xtools=true
case "x${Destdir##*/}" in
	'x') xtools=false ;;
	*) break ;;
esac

c -cd "v$Version.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/ksh-$Version"

# Clean the source code tree.
[ -d ./arch/ ] && ./bin/package clean

if $xtools; then
	CC=clang
	CXX=clang++
	AR=llvm-ar
	RANLIB=llvm-ranlib
	# Hack the main control script (bin/package) from
	# ksh93's build system so it forcefully uses
	# /llvmtools/bin; /opt/ast/bin won't be necessary
	# too soon.
	sed >"$trash/ksh93-package.sh" \
		's@\(^PATH=$(sanitize_PATH "\)/opt/ast\(.*\)@\1/llvmtools\2@g' \
		./bin/package
	cat "$trash/ksh93-package.sh" > ./bin/package
fi
export CC CXX AR RANLIB

sh ./bin/package make
mkdir -p "$Destdir/bin"
install -m755 "arch/$(bin/package host type)/bin/ksh" "$Destdir/bin"
if ! $xtools; then
	./bin/package install "$Destdir"
	(
		cd "$Destdir"
		# Place include and share inside /usr again.
		mkdir ./usr
		mv ./share ./include ./usr
		(
			cd ./usr
			mkdir -p ./share/lib
			(
				# Move ksh93's 'fun' snippets to /usr/share/lib.
				cd ./share
				mv ./fun ./lib
			)
		)
	)
else
	# Link ksh to sh and ksh93.
	(
		cd "$Destdir/bin"
		ln -s {k,}sh
		ln -s ksh{,93}
	)
fi
