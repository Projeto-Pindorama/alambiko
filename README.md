# Alambiko

Alambiko is the repository that contains all the build recipes to Copacabana Linux
packages.
It's similar in spirit to ``salsa.debian.org``, ``git.centos.org/rpms`` and many,
many others.

## Trivia

"Alambiko" (ˌalambˈiko) means "alembic" in Esperanto.

## ``pkgbuild`` template

Below theres an example of a ``pkgbuild`` file. Some functions, such as ``c()``,
are present in the script that will run the instructions present at those files.  
For now, this is a big W.I.P., since how everything will work still being
discussed. If you have any suggestions, open an Issue. 
The main idea of this is to provide both a less laborous way to build Copacabana
from source, using a build consolidation and to provide references for other
folks building musl C library-based Linux distributions. 

```sh
# vim: set filetype=sh :
Name="Fubá"
Vendor="Pindorama"
Description="Fubá flour-based utilities."
Version="0.0"
Archive_name="fuba.$Version.tar.xz"
Depends_on=("base/kernel-headers", "base/LibC")
Maintainer="Barão de Mauá"
Hotline="irineu.evangelista@correios.gov.br"

Destdir="/usr/tmp/fuba-$Version"

unarchive() {
	c -cd "$Archive_name" | tar -xvf - -C "$OBJDIR" \
		&& chdir "$OBJDIR/fuba_$Version"

}

configure() {
	./configure --prefix=/usr \
		--libdir=/lib \
		--pkgconfigdir=/usr/share/lib/pkgconfig
}

build() {
	unarchive
	configure
	gmake -j$THREADS \ 
		&& DESTDIR="$Destdir" gmake install
}
```

## Licence

The UUIC/NCSA licence, as Copacabana work itself.
