# vim: set filetype=sh :

case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

c -cd "netbsd-curses-${Version}.tar.xz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/netbsd-curses-${Version}"

# Clean the source code tree, in case of anything has been compiled before.
gmake clean

# Fix the GNUmakefile, making $(PREFIX) "resettable"
# per the environment variable.
sed >"$trash/NBSDcurses.GNUmakefile" \
	'/^PREFIX[^?]/s/\(.*\)=\(.*\)/\1?=\2/' ./GNUmakefile &&
	cat "$trash/NBSDcurses.GNUmakefile" >./GNUmakefile

CC=clang
CXX=clang++
AR=llvm-ar
RANLIB=llvm-ranlib
case "$stage" in
	second)
		PREFIX='/'
		# Faster build; no reason for optimizing
		# it just for the toolchain.
		C_FLAGS='-O0'
		;;
	final)
		# Correct the pkgconfig directory location.
		sed >"$trash/NBSDcurses.GNUmakefile" -e '/^PREFIX/a\
SHARELIBDIR=$(PREFIX)/share/lib' \
			-e '/pkgconfig/s/LIBDIR/SHARELIBDIR/g' ./GNUmakefile &&
			cat "$trash/NBSDcurses.GNUmakefile" >./GNUmakefile

		PREFIX=/usr
		C_FLAGS="$CFLAGS -static"
		;;
esac
export CC CXX AR RANLIB PREFIX
gmake -j$(nproc) &&
	CFLAGS="$C_FLAGS" DESTDIR="$Destdir" gmake install
case "$stage" in
	final)
		# Place the dynamic libraries on the root of the filesystem.
		mv "$Destdir/usr/lib/"lib{curses,form,menu,panel,terminfo}.so "$Destdir/lib" &&
			for symlink in "$Destdir/usr/lib/"lib{curses,form,menu,panel,terminfo}.so; do
				# Remake the links.
				[ -L "$symlink" ] && rm "$symlink"
				case "$symlink" in
					*libcurses*\.so) tolink=libcurses.so ;;
					*libmenu*\.so) tolink=libmenu.so ;;
					*libpanel*\.so) tolink=libpanel.so ;;
					*libtermcap*\.so) tolink=libterminfo.so ;;
				esac
				ln -s "/lib/$tolink" "$symlink"
			done
		;;
esac

unset CC CXX AR RANLIB PREFIX C_FLAGS
