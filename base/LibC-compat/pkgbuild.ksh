# vim: set filetype=sh :
xtools=true
case "x${Destdir##*/}" in
	'x') xtools=false ;;
	*) ;;
esac

c -cd "$Version.tar.gz" | tar -xf - -C "$OBJDIR"

cd "$OBJDIR/musl-compat-$Version"

gmake clean

# Pre-create directories at $Destdir
# before running install(1b).
# This will be fixed in the next release.
# install(1b) will give a cryptical response,
# with the name of the file to be installed
# along with "No such file or directory".
mkdir -p "$Destdir/usr/include/sys" \
	"$Destdir/usr/share/man/man3" \
	"$Destdir/usr/lib"
if $xtools; then
	INSTALL=install ROOT="$Destdir" \
		gmake install-sysheaders
else
	gmake -j$(nproc)
	ROOT="$Destdir" gmake install
fi
