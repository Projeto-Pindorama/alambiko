case "x${Destdir##*/}" in
	'x') stage='final' ;;
	'xllvmtools') stage='second' ;;
esac

mkdir -p "$OBJDIR/copausrspc"
c -cd "heirloom-$Version.tar.bz2" | tar -xf - -C "$OBJDIR/copausrspc"
cd "$OBJDIR/copausrspc/"

# Disable both Heirloom tar and man, since these are provided
# per schilytools and OpenBSD (mandoc), respectively.
# Also, Heirloom tar is broken (see issue #44 at the
# heirloom-ng GitHub repository).
sed >"$trash/HeirloomNG.makefile" \
	"$(echo 's/'{man,tar}'//;')" ./makefile
cp "$trash/HeirloomNG.makefile" ./makefile

case "$stage" in
	second)
		_CFLAGS="-O0 -fomit-frame-pointer"
		gmake -C "./heirloom-ng-${HeirloomNG_Version}" \
			CFLAGS="$_CFLAGS" \
			CFLAGSS="$_CFLAGS" \
			CFLAGS2="$_CFLAGS" \
			CFLAGSU="$_CFLAGS" \
			DEFBIN=/bin SV3BIN=/bin S42BIN=/bin/s42 \
			SUSBIN=/bin/posix SU3BIN=/bin/posix2001 UCBBIN=/bin \
			CCSBIN=/bin \
			DEFLIB=/lib DEFSBIN=/sbin MANDIR=/tmp/__man__ \
			DFLDIR=/dev/null SPELLHIST=/dev/null \
			SULOG=/dev/null
		unset _CFLAGS
		;;
	final)
		gmake -C "./heirloom-ng-${HeirloomNG_Version}" \
			CFLAGS="$CFLAGS -fomit-frame-pointer -O" \
			CFLAGSS="$CFLAGS -fomit-frame-pointer -Os" \
			CFLAGS2="$CFLAGS -O2" \
			CFLAGSU="$CFLAGS -fomit-frame-pointer -funroll-loops -O2" \
			DEFBIN=/usr/bin SV3BIN=/usr/5bin S42BIN=/usr/5bin/s42 \
			SUSBIN=/usr/5bin/posix SU3BIN=/usr/5bin/posix2001 UCBBIN=/usr/ucb \
			CCSBIN=/usr/ccs/bin \
			DEFSBIN=/sbin DEFLIB=/usr/lib/5lib MANDIR=/usr/share/man
		;;
esac

gmake -C "./heirloom-ng-${HeirloomNG_Version}" \
	ROOT="$Destdir" instal

# Yet to be tested.
case "$stage" in
	second)
	       	# Create symbolic links for the programs that
		# will be needed at the chroot stage.
		(
			cd "$Destdir/../" &&
				mkdir ./bin &&
				apply 'ln -s /llvmtools/bin/%1 ./bin/%1' cat dd echo \
					install ksh ln pwd rm stty
				ln -s ksh ./bin/sh # Temporary until we build dash later.
		)
		;;
	final)
		# Place most important binaries at the /bin.
		(
			cd "$Destdir" &&
				mkdir ./bin &&
				mkdir ./usr/sbin &&
				apply 'mv %1 ./bin/' usr/5bin/{basename,bfs,chmod,cp,\
date,du,echo,ed,expr,{,e,f}grep,lc,ln,ls,mkdir,mv,rmdir,sed,test,touch,who} &&
				apply 'mv %1 ./bin/' usr/bin/{STTY,cat,ch{grp,own},cpio,\
copy,dd,dirname,df{,space},false,hostname,install,listusers,logname,mk{fifo,nod},mt,mvdir,\
pathchk,pkill,pwd,rm,settime,sleep,stty,sync,tape{,cntl},tcopy,true,tty,uname,uptime,users,\
w,whoami,whodo} &&
				mv usr/bin/logins usr/sbin &&
				# Remake links to /usr/5bin and /usr/ucb.
				apply 'cd "`dirname "%1"`"; p="`basename "%1"`"; ln -sf "../../bin/$p" "$p"' \
					usr/5bin/basename usr/5bin/bfs usr/5bin/chmod usr/5bin/cp \
				       	usr/5bin/date usr/5bin/du usr/5bin/echo usr/5bin/ed \
					usr/5bin/expr usr/5bin/grep usr/5bin/egrep usr/5bin/fgrep \
					usr/5bin/lc usr/5bin/ln usr/5bin/ls usr/5bin/mkdir usr/5bin/mv \
					usr/5bin/rmdir usr/5bin/sed usr/5bin/test usr/5bin/touch usr/5bin/who \
					usr/ucb/hostname usr/ucb/tcopy usr/ucb/uptime usr/ucb/w usr/ucb/whoami &&
				apply 'cd "`dirname "%1"`"; p="`basename "%1"`"; ln -sf "../../../bin/$p" "$p"' \
					usr/5bin/s42/basename usr/5bin/s42/chmod usr/5bin/s42/du \
					usr/5bin/s42/echo usr/5bin/s42/lc usr/5bin/s42/ls \
					usr/5bin/s42/rm usr/5bin/s42/rmdir usr/5bin/s42/test \
					usr/5bin/s42/touch usr/5bin/s42/who
		)
		;;
esac
