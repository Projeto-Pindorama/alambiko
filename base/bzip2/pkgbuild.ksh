# vim: set filetype=sh :
xtools=true
case "x${Destdir##*/}" in
	'x') xtools=false ;;
	*) break ;;
esac

c -cd "bzip2-bzip2-$Version.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/bzip2-bzip2-$Version"

# Make our life easier later on, create a $(ROOT) variable.
sed "/^ROOT[?]=/d; /^PREFIX/a\\
ROOT=
; $(echo '/$(PREFIX)/s/\('{'test ! -d','.*'}' \)\($(PREFIX)\)\(.*\)/\1$(ROOT)\2\3/;')" \
	./Makefile >"$trash/bzip2.Makefile" &&
	cp "$trash/bzip2.Makefile" ./Makefile

# Remove the need of running the 'test' target, also make links relative to the
# file name on the same directory, not the entire PATH, and install the manual
# page files to "$(PREFIX)/share/man" and not "$(PREFIX)/man".
sed -e '/^all:/s@ test@@; s@\(ln -s -f \)$(PREFIX)/bin/@\1@' \
	-e "$(echo 's@\('{'test ! -d ',}'.*$(PREFIX)\)\(/man\)@\1/share\2@g;')" \
	./Makefile >"$trash/bzip2.Makefile" &&
	cp "$trash/bzip2.Makefile" ./Makefile

# Make the compiler, ar and ranlib "choosable".
# We can give ourselves the commodity to do this because we're running the
# Makefile from GNU Make.
sed "$(echo '/^'{CC,AR,RANLIB}'[^?]/s/\(.*\)=\(.*\)/\1?=\2/;')" ./Makefile \
	>"$trash/bzip2.Makefile" &&
	cp "$trash/bzip2.Makefile" ./Makefile
# Also apply this for libbz2.so Makefile, which just has CC hardcoded as 'gcc'.
sed '/^CC[^?]/s/\(.*\)=\(.*\)/\1?=\2/' ./Makefile-libbz2_so \
	>"$trash/bzip2.Makefile-libbz2_so" &&
	cp "$trash/bzip2.Makefile-libbz2_so" ./Makefile-libbz2_so

# Also the PREFIX and ROOT, to where it will be installed.
sed "$(echo '/^'{PREFIX,ROOT}'[^?]/s/\(.*\)=\(.*\)/\1?=\2/;')" ./Makefile \
	>"$trash/bzip2.Makefile" &&
	cp "$trash/bzip2.Makefile" ./Makefile

# Only enable changes to LDFLAGS in case of compiling to the base system.
if ! $xtools; then
	sed '/^LDFLAGS[^?]/s/\(.*\)=\(.*\)/\1?=\2/' ./Makefile \
		>"$trash/bzip2.Makefile" &&
		cp "$trash/bzip2.Makefile" ./Makefile
fi

# Clean the source code tree.
gmake clean

if $xtools; then
	PREFIX=/
	AR=llvm-ar
	CC=${TARGET_TUPLE}-clang
	RANLIB=llvm-ranlib
else
	PREFIX=/usr
	AR=ar
	CC=cc
	RANLIB=ranlib
	LDFLAGS='-static'
fi
ROOT="$Destdir"

gmake -f Makefile-libbz2_so -j$(nproc) \
	CC=$CC &&
	gmake clean

gmake -j$(nproc) \
	AR=$AR \
	CC=$CC \
	RANLIB=$RANLIB \
	LDFLAGS="$LDFLAGS" &&
	gmake install PREFIX="$PREFIX" ROOT="$ROOT"

if ! $xtools; then
	mkdir "$Destdir/lib"
	cp libbz2.?.?.? "$Destdir/lib"
	(
		cd "$Destdir/lib"
		ln -s libbz2.so.?.?.? 'libbz2.so.1'
		ln -s 'libbz2.so'{.1,}
	)
fi
