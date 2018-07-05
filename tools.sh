#!/usr/bin/env bash

# $0    当前脚本的文件名
# $n    传递给脚本或函数的参数。n 是一个数字，表示第几个参数。例如，第一个参数是$1，第二个参数是$2。
# $#    传递给脚本或函数的参数个数。
# $*    传递给脚本或函数的所有参数。
# $@    传递给脚本或函数的所有参数。被双引号(" ")包含时，与 $* 稍有不同，下面将会讲到。
# $?    上个命令的退出状态，或函数的返回值。
# $$    当前Shell进程ID。对于 Shell 脚本，就是这些脚本所在的进程ID。

# ${file#*/}：删掉第一个 / 及其左边的字符串：dir1/dir2/dir3/my.file.txt
# ${file##*/}：删掉最后一个 /  及其左边的字符串：my.file.txt
# ${file#*.}：删掉第一个 .  及其左边的字符串：file.txt
# ${file##*.}：删掉最后一个 .  及其左边的字符串：txt
# ${file%/*}：删掉最后一个  /  及其右边的字符串：/dir1/dir2/dir3
# ${file%%/*}：删掉第一个 /  及其右边的字符串：(空值)
# ${file%.*}：删掉最后一个  .  及其右边的字符串：/dir1/dir2/dir3/my.file
# ${file%%.*}：删掉第一个  .   及其右边的字符串：/dir1/dir2/dir3/my

#  所有输出重定向到黑洞中 >/dev/null 2>&1;

tools_array_contains () {
    local seeking=$1; shift
    local in=1
    for element; do
        if [[ ${element} == ${seeking} ]]; then
            in=0
            echo 0
            break
        fi
    done
    return $in
}

tools_echo_file_size_string() {
    size=$1
    size=$(echo "${size}" | awk '{ split( "B KB MB GB TB PB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } printf "%.2f %s", $1, v[s] }')
    echo ${size}
}

tools_check_brew_libs_and_install() {
    if [[ ! $(which brew) ]]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        sudo chown -R $(whoami) $(brew --prefix)/*
    fi
    _brew_installed_list=$(brew list)
    _will_install_apps=$1
    if [[ ! -n "$_will_install_apps" ]]; then
        return
    fi
    for value in ${_will_install_apps[@]}
    do
        if [[ ! $(tools_array_contains ${value} ${_brew_installed_list}) ]]; then
            brew install ${value}
        fi
    done
}

tools_check_brew_cask_libs_and_install() {
    if [[ ! $(which brew) ]]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        sudo chown -R $(whoami) $(brew --prefix)/*
    fi
    _brew_cask_installed_list=$(brew cask list)
    _will_install_apps=$1
    if [[ ! -n "$_will_install_apps" ]]; then
        return
    fi
    for value in ${_will_install_apps[@]}
    do
        if [[ ! $(tools_array_contains ${value} ${_brew_cask_installed_list}) ]]; then
            brew cask install ${value}
        fi
    done
}

tools_openProxy() {
    INPUT_PROXY_ADDRESS=$1
    if [[ ${INPUT_PROXY_ADDRESS} != http* ]]; then
        INPUT_PROXY_ADDRESS="http://$INPUT_PROXY_ADDRESS"
    fi
    export http_proxy=${INPUT_PROXY_ADDRESS}
    export https_proxy=${INPUT_PROXY_ADDRESS}
    export ALL_PROXY=${INPUT_PROXY_ADDRESS}
    git config --global http.proxy ${INPUT_PROXY_ADDRESS}
    git config --global https.proxy ${INPUT_PROXY_ADDRESS}
}

tools_closeProxy() {
    unset http_proxy
    unset https_proxy
    unset ALL_PROXY
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    sed -i -e '/^\[http\]/d;/^\[https\]/d' ~/.gitconfig
}

