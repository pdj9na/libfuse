#!/bin/bash
# $1 获取时间的文件;

fun_change(){
    ! declare -p __CHANGETIMEDIC_ &>/dev/null && {
        declare -Ag __CHANGETIMEDIC_
        declare -Ag __ISCHANGETIMEDIC_
        __FILE_=.vscode/.changeTime_files
        test -r $__FILE_ && {
            . $__FILE_
            echo -e '\c' >$__FILE_
            #echo ${__CHANGETIMEDIC_[*]}
        }
    }

    test -z "${__CHANGETIMEDIC_[$1]}" && __CHANGETIMEDIC_[$1]=0
    local CTNew=`stat -c %Y $1`
    #echo $CTNew
    echo '__CHANGETIMEDIC_['$1']='$CTNew >>$__FILE_
    __ISCHANGETIMEDIC_[$1]=`test "$CTNew" -gt "${__CHANGETIMEDIC_[$1]}" -o x$2 = 'x-f' && echo 0 || echo 1`
}

# $2 是否强制 -f
fun_changes(){
    local i
    echo $1
    for i in $1;do
        fun_change $i $2
    done
    cat $__FILE_
    echo '__ISCHANGETIMEDIC_ 列表：'${__ISCHANGETIMEDIC_[*]}
}

# 判断多个文件是否存在修改
fun_isChangeFromMulti(){
    echo 'fun_isChangeFromMulti: '$1
    local ret=1 i
    for i in $1;do
        test x${__ISCHANGETIMEDIC_[$i]} = x0 && {
            ret=0
            break
        }
    done
    return $ret
}

# 判断Makefile.am文件是否修改，如果修改，就清除生成文件并重新创建Makefile文件
# $1 *.am文件列表
fun_whereMakeClean(){
    local __i
    for __i in $1;do
        test x${__ISCHANGETIMEDIC_[$__i]} = x0 && {
            #echo ${__i}
            #echo ${__i%%/*}
            test ${__i%%/*} = ${__i} -o ${__i%%/*} = .vscode && __i=.
            make -C ${__i%%/*} clean
            test ${__i%%/*} = . && break
        }
    done
}
