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


# 删除之前运行 configure 的状态，使再次运行 configure 能够立即应用新的参数
rm -f config.status
if fun_isChangeFromMulti configure.ac;then
	type autoreconf &>/dev/null && sh ./makeconf.sh
fi

#if fun_isChangeFromMulti configure.ac;then
if fun_isChangeFromMulti "$__ACFILES_";then

	#使目标执行程序执行时不输出： unused DT entry: type 0xf arg 0x1ee
	_args="--disable-rpath"
	if type busybox &>/dev/null && test `busybox uname -o` = Android ||
	`uname -m` = aarch64 || `uname -m` = aarch;then
		export CONFIG_SHELL=/system/bin/sh
		
		#https://blog.csdn.net/abcdu1/article/details/86083295
		#如果库目录存在动态库文件，就会默认加载动态库，并无视Makefile.am
		#	中LIBADD显式指定静态库，如“-l:libandroid_support.a”
		#只有库目录不存在动态库文件，才会加载静态库，且不需要设置 LD_LIBRARY_PATH
		# 否则加载动态库需要设置 LD_LIBRARY_PATH
		# 目标库使用configure选项 --disable-shared 禁止生成动态库
		#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:`readlink -f ../libandroid_support/lib/.libs`
		export LDFLAGS="-L`readlink -f ../libandroid_support/lib/.libs`"
		export CPPFLAGS="-I`readlink -f ../libandroid_support/include`"

		test `uname -m` = aarch && _args="--target=aarch-linux-android "$_args
		test `uname -m` = aarch64 && _args="--target=aarch64-linux-android "$_args
	else :
		#_args=$_args" --enable-asan"
	fi
	sh ./configure $_args
fi

# android c4droid 缺少automake 和autoconf
# 要使configure脚本不再依赖 aclocal,要保证以下文件没有被修改：
# configure.ac config.h aclocal.m4 /m4 /m4/*.m4 Makefile.am

fun_whereMakeClean "configure.ac $__AMFILES_"
#fun_whereMakeClean "$__ACFILES_ $__AMFILES_"

make -j4


find example/.libs -name *.so* -exec rm {} \;

ln -s ../../lib/.libs/libfuse.so.2   example/.libs/libfuse.so.2
ln -s ../../lib/.libs/libulockmgr.so.1  example/.libs/libulockmgr.so.1

