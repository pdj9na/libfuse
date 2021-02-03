#!/bin/bash

. .vscode/build_util.sh

 __ACFILES_="configure.ac\
 .vscode/build.sh"
 
__AMFILES_=" Makefile.am\
 doc/Makefile.am\
 example/Makefile.am\
 include/Makefile.am\
 lib/Makefile.am\
 util/Makefile.am"

fun_changes "$__ACFILES_ $__AMFILES_" -f

if fun_isChangeFromMulti configure.ac;then
	type autoreconf &>/dev/null && sh ./makeconf.sh
fi

#if fun_isChangeFromMulti configure.ac;then
if fun_isChangeFromMulti "$__ACFILES_";then
	if test `uname -o` = Android;then
		export CONFIG_SHELL=/system/bin/sh
		#export CPPFLAGS='-fPIE'
		export CFLAGS="-march=armv8-a\
 -O3\
 -D__ARM_ARCH_7__\
 -D__ARM_ARCH_7A__\
 -DPIC\
 -flax-vector-conversions\
 -Wunused-variable\
 -fPIE\
 -pie\
 -pthread"
	fi
	sh ./configure
fi

fun_whereMakeClean "configure.ac $__AMFILES_"
#fun_whereMakeClean "$__ACFILES_ $__AMFILES_"

make -j4


find example/.libs -name *.so* -exec rm {} \;
ln -sr lib/.libs/libfuse.so.2   example/.libs/libfuse.so.2
ln -sr lib/.libs/libulockmgr.so.1  example/.libs/libulockmgr.so.1

