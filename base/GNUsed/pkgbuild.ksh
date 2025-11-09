# vim: set filetype=sh :

case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

c -cd "gnu/sed-${Version}.tar.gz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/sed-${Version}"

# Patch sed invocations at ./configure for Heirloom sed.
# Perhaps we could've disabled intl/po file generation,
# but I'm not sure.
# See: https://lists.gnu.org/archive/html/bug-gnu-utils/2006-09/msg00063.html
# Mirror: https://bug-gnu-utils.gnu.narkive.com/w3TTqKLc/sed-command-garbled
sed >"$trash/GNUsed.configure" \
	-e '11268s/'\''/"/; 11273s/'\''/"/;' \
	-e '11268s/\(a\\\)'\''.*/\1\\/; 11273s/\(a\\\)'\''.*/\1\\/;' \
	-e '11269s/.*-e "\(.*\)/\1/; 11274s/.*-e "\(.*\)/\1/;' \
	./configure
cat "$trash/GNUsed.configure" > ./configure

[ -e Makefile ] && gmake distclean
if ! $xtools; then
	configure_opts=(
		"--prefix=/usr/gnu"
	)
	export CFLAGS LDFLAGS
else
	configure_opts=(
		"--prefix=/"
	)
fi

./configure ${configure_opts[@]}
gmake -j$(nproc) && gmake DESTDIR="$Destdir" install
