# Alambiko

Alambiko is the repository that contains all the build recipes to Copacabana Linux
packages.
It's similar in spirit to ``salsa.debian.org``, ``git.centos.org/rpms`` and many,
many others.

## Trivia

"Alambiko" (ˌalambˈiko) means "alembic" in Esperanto.

## Chip in!

### ``pkgbuild`` template

Below there is an example of a ``pkgbuild`` file.

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
	c -cd "$Archive_name" | tar -xvf - -C "$OBJDIR"
}

configure() {
	./configure --prefix=/usr \
		--libdir=/lib \
		--pkgconfigdir=/usr/share/lib/pkgconfig
}

post_install() { return 0; }

build() {
	gmake -j$(nproc) \
	&& DESTDIR="$Destdir" gmake install
}
```

All the functions defined above will be run by a script, it's not meant to be
called from ``build()`` anymore.

These are the functions currently implemented and ready to use on pkgbuilds:

| Function identifier | Description |
|---|---|
| ``basename`` | Strips directory and suffix from filenames. |
| ``c`` | Wrapper for decompressors that supports writing<br>the decompressed data to the standard output.<br>Currently it supports cat (for tarballs without<br>compression), bzip2, gzip and xz. |
| ``lines`` | Counts the quantity of lines, like ``wc -l``. |
| ``n`` | Counts elements. It's a workaround for the ``#``<br>macro present in GNU Broken-Again Shell 4.3, but<br>you can use it instead the aforesaid macro in<br>any shell that support arrays. |
| ``nproc`` | Counts processors in the machine, multiplatform (can<br>run on \*BSD, Darwin (MacOS), Linux and SunOS); |
| ``printerr`` | Prints messages to the standard error output |
| ``pushd`` | Push a directory onto a stack. |
| ``popd`` | "Pop" (remove) an directory from the stack and<br>changes into the last. |
| ``realpath`` | Gets the real path to files. |
| ``timeout`` | Runs a commmand with time limit. |

## Licence

The UUIC/NCSA licence, as Copacabana work itself.

