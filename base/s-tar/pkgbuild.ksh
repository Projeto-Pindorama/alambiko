# vim: set filetype=sh :
xtools=true
case "x${Destdir##*/}" in
	'x') xtools=false ;;
	*) break ;;
esac

c -cd "star-$Version.tar.bz2" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/star-$Version"

# Clean the source code tree.
gmake -j$(nproc) clean

if $xtools; then
	DESTDIR="${Destdir##*/}"
	INS_BASE=/
	CC=clang
else
	DESTDIR="$Destdir"
	INS_BASE=/usr
	CC=cc
fi

# ld.lld will run over its legs if
# we use more than 2 jobs here.
gmake CC=$CC INS_BASE="$INS_BASE" \
	&& gmake DESTDIR="$Destdir" \
		INS_BASE="$INS_BASE" \
		INSUSR=root \
		INSGRP=wheel \
		install

if ! $xtools; then
	mkdir -p "$Destdir"/{s,}bin
	(
		cd "$Destdir"
		mv ./usr/bin/s{mt,tar{_sym,}} ./bin &&
			mv ./usr/sbin/rmt ./sbin &&
			for link in {s{pax,cpio},{gnu,sun,,us}tar}; do
				if [ -L "./usr/bin/$link" ] &&
					rm -f "./usr/bin/$link"; then
					(
						cd ./bin
						ln star "$link"
					)
				fi
			done &&
			if [ -L ./usr/bin/mt ] &&
				rm -f ./usr/bin/mt; then
				(
					cd ./bin
					ln smt mt
				)
			fi
		cd ./usr/share/man/man1 && ln {s,}tar.1
	)
fi
