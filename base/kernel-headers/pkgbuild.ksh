# vim: set filetype=sh :
# Location to where it will be installed.
# In case of not being for the cross toolchain,
# it will be thrown into the usr/ directory.
case "x${Destdir##*/}" in
	'x') Destdir+='usr' ;;
	*) ;;
esac
Archive_name="linux-$Version.tar.xz"
c -cd "$Archive_name" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/linux-${Version}"
ARCH=$ARCH gmake headers
mkdir -p "$Destdir/include"
find usr/include/ \( ! -name 'Makefile' ! -name '.*' \
	! -name '.*.cmd' \) -depth -print | cpio -pdm "$Destdir"
