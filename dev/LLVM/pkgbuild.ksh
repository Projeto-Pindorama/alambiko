# vim: set filetype=sh :

# Set if we're building the final LLVM (for /usr/ccs), the second
# stage (for /llvmtools) or the first stage (/cgnutools).
case "x${Destdir##*/}" in
	'x')
		LLVM_new_vendor="Copacabana $COPA_VERSION"
		stage='final'
		;;
	'xllvmtools')
		LLVM_new_vendor="Copacabana (llvmtools) $COPA_VERSION"
		stage='second'
		;;
	'xcgnutools')
		LLVM_new_vendor="Copacabana (cgnutools) $COPA_VERSION"
		stage='first'
		;;
esac

c -cd "dev/llvm-project-${Version}.src.tar.xz" | tar -xf - -C "$OBJDIR"
cd "$OBJDIR/llvm-project-${Version}.src"

[ -d build ] && rm -rf ./build
if [[ $stage =~ (first|second) ]]; then
	# Hack clang(1) from the source to use the dynamic loader
	# from /llvmtools; also apply changes to the tests.
	sed >"$trash/LLVM-Linux.cpp" 's@"\(/lib/ld-musl-\)"@"/llvmtools\1"@g' \
		./clang/lib/Driver/ToolChains/Linux.cpp
	cat "$trash/LLVM-Linux.cpp" >./clang/lib/Driver/ToolChains/Linux.cpp
	sed >"$trash/LLVM-test-linux-ld.c" 's@"\(/lib/ld-musl-.*\)"@"/llvmtools\1"@g' \
		./clang/test/Driver/linux-ld.c
	cat "$trash/LLVM-test-linux-ld.c" >./clang/test/Driver/linux-ld.c

	# Set the compiler and linker flags
	CRT="-DCOMPILER_RT_BUILD_SANITIZERS=OFF "
	CRT+="-DCOMPILER_RT_BUILD_XRAY=OFF "
	CRT+="-DCOMPILER_RT_BUILD_LIBFUZZER=OFF "
	CRT+="-DCOMPILER_RT_BUILD_PROFILE=OFF "
	CRT+="-DCOMPILER_RT_BUILD_MEMPROF=OFF "
	CRT+="-DCOMPILER_RT_BUILD_GWP_ASAN=OFF "
	CTG="-DLLVM_DEFAULT_TARGET_TRIPLE=${TARGET_TUPLE} "
	CTG+="-DLLVM_HOST_TRIPLE=${TARGET_TUPLE} "
	CTG+="-DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=${TARGET_TUPLE} "
	CLG="-DCLANG_DEFAULT_CXX_STDLIB=libc++ "
	CLG+="-DCLANG_DEFAULT_RTLIB=compiler-rt "
	CLG+="-DCLANG_DEFAULT_UNWINDLIB=libunwind "
	CLG+="-DCLANG_DEFAULT_CXX_STDLIB=libc++ "
	CLCPP="-DLIBCXX_HAS_MUSL_LIBC=ON "
	CLCPP+="-DLIBCXX_ENABLE_LOCALIZATION=ON "
	CLCPP+="-DLIBCXX_ENABLE_NEW_DELETE_DEFINITIONS=ON "
	CLCPP+="-DLIBCXX_CXX_ABI=libcxxabi "
	CLCPP+="-DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON "
	CLCPP+="-DLIBCXX_ENABLE_ASSERTIONS=ON "
	CLCPPA="-DLIBCXXABI_USE_LLVM_UNWINDER=ON "
	CLCPPA+="-DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON "
	CUW="-DLIBUNWIND_INSTALL_HEADERS=ON "
	CLLVM="-DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON "
	CLLVM+="-DLLVM_ENABLE_ZLIB=ON "
	CLLVM+="-DLLVM_INSTALL_UTILS=ON "
	CLLVM+="-DLLVM_BUILD_LLVM_DYLIB=ON "
	CLLVM+="-DLLVM_LINK_LLVM_DYLIB=ON "
	CLLVM+="-DENABLE_LINKER_BUILD_ID=ON "
	CLLVM+="-DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON "
	COFF="-DLLVM_ENABLE_ZSTD=OFF -DLLVM_ENABLE_LIBEDIT=OFF "
	COFF+="-DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_LIBEDIT=OFF "
	COFF+="-DLLVM_ENABLE_TERMINFO=OFF -DLLVM_ENABLE_LIBPFM=OFF "
	if [[ $stage == 'first' ]]; then
		CFLAGS='-fPIC -I/cgnutools/include -Wl,-rpath=/cgnutools/lib '
		CT="-DCMAKE_C_COMPILER=${TARGET_TUPLE}-gcc "
		CT+="-DCMAKE_CXX_COMPILER=${TARGET_TUPLE}-g++ "
		CT+="-DCMAKE_AR=/cgnutools/bin/${TARGET_TUPLE}-ar "
		CT+="-DCMAKE_NM=/cgnutools/bin/${TARGET_TUPLE}-nm "
		CT+="-DCMAKE_RANLIB=/cgnutools/bin/${TARGET_TUPLE}-ranlib "
		CT+="-DCLANG_DEFAULT_LINKER=/cgnutools/bin/ld.lld "
		CT+="-DGNU_LD_EXECUTABLE=/cgnutools/bin/${COPA_TARGET}-ld.bfd "
		CTG+="-DLLVM_TARGETS_TO_BUILD=host "
		CP="-DCMAKE_INSTALL_PREFIX=/cgnutools "
		CRT+="-DCOMPILER_RT_USE_LLVM_UNWINDER=ON "
		CRT+="-DCOMPILER_RT_USE_BUILTINS_LIBRARY=OFF "
		CLCPP+="-DLIBCXX_USE_COMPILER_RT=OFF "
		CLCPPA+="-DLIBCXXABI_USE_COMPILER_RT=OFF "
	elif [[ $stage == 'second' ]]; then
		CFLAGS="-fPIC -I/cgnutools/include"
		CT="-DCMAKE_C_COMPILER=${TARGET_TUPLE}-clang "
		CT+="-DCMAKE_CXX_COMPILER=${TARGET_TUPLE}-clang++ "
		CT+="-DCMAKE_AR=/cgnutools/bin/llvm-ar "
		CT+="-DCMAKE_NM=/cgnutools/bin/llvm-nm "
		CT+="-DCMAKE_RANLIB=/cgnutools/bin/llvm-ranlib "
		CT+="-DCLANG_DEFAULT_LINKER=/llvmtools/bin/ld.lld "
		CP="-DCMAKE_INSTALL_PREFIX=/llvmtools "
		CRT+="-DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON "
		CRT+="-DCOMPILER_RT_CXX_LIBRARY=libcxx "
		CRT+="-DCOMPILER_RT_USE_LLVM_UNWINDER=ON "
		CLCPPA+="-DLIBCXXABI_USE_COMPILER_RT=ON "
		CUW+="-DLIBUNWIND_USE_COMPILER_RT=ON "
		CLLVM+="-DLLVM_ENABLE_LIBCXX=ON "
		CLLVM+="-DLLVM_ENABLE_LLD=ON "
		CLLVM+="-DZLIB_INCLUDE_DIR=/llvmtools/include "
		CLLVM+="-DZLIB_LIBRARY_RELEASE=/llvmtools/lib/libz.so "
		COFF+="-DLLVM_INCLUDE_BENCHMARKS=OFF "
	fi
	CTG+="-DLLVM_TARGET_ARCH=host "
	CTG+="-DLLVM_TARGETS_TO_BUILD=Native;host "
	CP+="-DDEFAULT_SYSROOT=/llvmtools "

fi # final or clang rebuild
CXXFLAGS="$CFLAGS"
export CFLAGS CXXFLAGS

cmake -G Ninja -B build -S llvm -Wno-dev \
	-DCMAKE_BUILD_TYPE=Release \
	-DLLVM_ENABLE_RUNTIMES='compiler-rt;libunwind;libcxx;libcxxabi' \
	-DLLVM_ENABLE_PROJECTS='clang;lld' \
	-DCLANG_VENDOR="$LLVM_new_vendor" -DLLD_VENDOR="$LLVM_new_vendor" \
	$CT $CTG $CP $CRT $CLG $CLCPP $CLCPPA $CUW $CLLVM $COFF

unset CT CTG CP CRT CLG CLCPP CLCPPA CUW CLLVM COFF
ninja -C build -j5
DESTDIR="${Destdir%/*}" cmake --install build --strip

(
	cd "$Destdir"
	(
		cd bin
		ln clang-17 cc
		ln ld.lld ld
	)
)
case "$stage" in
	'first')
		[ -e /cgnutools/bin/ld ] && mv /cgnutools/bin/ld{,-nouse}
		# Change the location for the G.C.C. instalation libraries, ergo
		# LLVM will not search for crt[i,1,n].o files there.
		mv /cgnutools/lib/gcc{,-nouse}
		(
			cd "$Destdir/bin"
			ln clang-17 ${TARGET_TUPLE}-clang
			ln clang-17 ${TARGET_TUPLE}-clang++
		)
		printf >"$Destdir/bin/${TARGET_TUPLE}.cfg" \
			'-L/cgnutools/lib\n-L/cgnutools/lib/%s\n-nostdinc++\n' \
			"$TARGET_TUPLE"
		printf >>"$Destdir/bin/${TARGET_TUPLE}.cfg" \
			'-I/cgnutools/include/c++/v1\n-I/cgnutools/include/%s/c++/v1\n-I/llvmtools/include\n' \
			"$TARGET_TUPLE"
		# Amend /cgnutools' library path to /llvmtools'.
		(
			cat "/llvmtools/etc/ld-musl-${MUSL_ARCH}.path"
			printf '/cgnutools/lib/%s\n' "$TARGET_TUPLE"
			echo '/cgnutools/lib'
		) >"$trash/ld-musl-${MUSL_ARCH}.path"
		mkdir -p "${Destdir%/*}/llvmtools/etc"
		cat "$trash/ld-musl-${MUSL_ARCH}.path" \
			>"${Destdir%/*}/llvmtools/etc/ld-musl-${MUSL_ARCH}.path"
		;;
	'second')
		mkdir "$Destdir/usr"
		(
			cd "$Destdir/usr"
			ln -s ../include .
		)
		;;
esac
