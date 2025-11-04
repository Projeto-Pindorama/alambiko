# vim: set filetype=sh :
xtools=true
case "x${Destdir##*/}" in
	'x') xtools=false ;;
	*) break ;;
esac

c -cd "pigz-$Version.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/pigz-$Version"

sed '/^CC[^?]/s/CC=\(.*\)/CC?=\1/' ./Makefile \
	>"$trash/pigz.Makefile" &&
	cp "$trash/pigz.Makefile" ./Makefile
if ! $xtools; then
	sed '/^LDFLAGS[^?]/s/\(.*\)=\(.*\)/\1?=\2/' ./Makefile \
		>"$trash/pigz.Makefile" &&
		cp "$trash/pigz.Makefile" ./Makefile
fi

# Clean the source code tree.
gmake clean

if $xtools; then
	CC=clang
else
	LDFLAGS='-static'
fi
export CC LDFLAGS

gmake -j"$(nproc)"
mkdir -p "$Destdir/bin" &&
	for cmd in pigz unpigz; do
		install -m755 "$cmd" "$Destdir/bin"
	done &&
	(
		cd "$Destdir/bin" &&
			ln pigz gzip &&
			ln unpigz gunzip
	)
if ! $xtools; then
	mkdir -p "$Destdir/usr/share/man/man1"
	install -m444 pigz.1 "$Destdir/usr/share/man/man1" &&
		(
			cd "$Destdir/usr/share/man/man1"
			ln -s pigz.1 gzip.1
		)
fi
