#!/usr/bin/env bash

# $0	当前脚本的文件名
# $n	传递给脚本或函数的参数。n 是一个数字，表示第几个参数。例如，第一个参数是$1，第二个参数是$2。
# $#	传递给脚本或函数的参数个数。
# $*	传递给脚本或函数的所有参数。
# $@	传递给脚本或函数的所有参数。被双引号(" ")包含时，与 $* 稍有不同，下面将会讲到。
# $?	上个命令的退出状态，或函数的返回值。
# $$	当前Shell进程ID。对于 Shell 脚本，就是这些脚本所在的进程ID。

# ${file#*/}：删掉第一个 / 及其左边的字符串：dir1/dir2/dir3/my.file.txt
# ${file##*/}：删掉最后一个 /  及其左边的字符串：my.file.txt
# ${file#*.}：删掉第一个 .  及其左边的字符串：file.txt
# ${file##*.}：删掉最后一个 .  及其左边的字符串：txt
# ${file%/*}：删掉最后一个  /  及其右边的字符串：/dir1/dir2/dir3
# ${file%%/*}：删掉第一个 /  及其右边的字符串：(空值)
# ${file%.*}：删掉最后一个  .  及其右边的字符串：/dir1/dir2/dir3/my.file
# ${file%%.*}：删掉第一个  .   及其右边的字符串：/dir1/dir2/dir3/my

# >/dev/null 2>&1 所有输出重定向到黑洞中

echo -e -n "\033[36m请输入管理员密码:\033[m"
read -s INPUT_SUOD_PASSWORD
echo
echo $INPUT_SUOD_PASSWORD | sudo -S -v;
echo

 echo -e "\033[36m >>>>>>>>>>>>>> 开启全局代理 <<<<<<<<<<<<<< \033[0m"
 export http_proxy=http://127.0.0.1:1087
 export https_proxy=http://127.0.0.1:1087
 export ALL_PROXY=http://127.0.0.1:1087
 git config --global http.proxy 'http://127.0.0.1:1087'
 git config --global https.proxy 'http://127.0.0.1:1087'
 echo -e "\033[36m >>>>>>>>>>>>>> 成功开启全局代理<<<<<<<<<<<<<< \033[0m"


if [[ -d "$ZSH" ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> oh my zsh updating <<<<<<<<<<<<<< \033[0m"
  upgrade_oh_my_zsh 
fi

if [[ $(which brew) ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> brew updating <<<<<<<<<<<<<< \033[0m"
  brew update 
  echo -e "\033[36m >>>>>>>>>>>>>> brew upgrading <<<<<<<<<<<<<< \033[0m"
  brew upgrade
  brew cleanup
  echo -e "\033[36m >>>>>>>>>>>>>> brew cask upgrading <<<<<<<<<<<<<< \033[0m"
  brew cask upgrade
  brew cask cleanup
fi

if [[ $(which pip2) ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> pip2 upgrading <<<<<<<<<<<<<< \033[0m"
  sudo -H pip2 install --upgrade pip
  sudo -H pip2 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip2 install -U
fi

if [[ $(which pip3) ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> pip3 upgrading <<<<<<<<<<<<<< \033[0m"
  sudo -H pip3 install --upgrade pip
  sudo -H pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip3 install -U
fi

if [[ $(which gem) ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> update_rubygems <<<<<<<<<<<<<< \033[0m"
  update_rubygems 
  echo -e "\033[36m >>>>>>>>>>>>>> gem update system <<<<<<<<<<<<<< \033[0m"
  sudo gem update --system
  echo -e "\033[36m >>>>>>>>>>>>>> gem update <<<<<<<<<<<<<< \033[0m"
  sudo gem update
fi

if [[ $(which pod) ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> updating pods <<<<<<<<<<<<<< \033[0m"
  pod repo update
fi

echo -e "\033[36m >>>>>>>>>>>>>> 关闭全局代理 <<<<<<<<<<<<<< \033[0m"
unset http_proxy
unset https_proxy
unset ALL_PROXY
git config --global --unset http.proxy
git config --global --unset https.proxy
sed -i -e '/^\[http\]/d;/^\[https\]/d' ~/.gitconfig
echo -e "\033[36m >>>>>>>>>>>>>> 成功关闭全局代理<<<<<<<<<<<<<< \033[0m"


## 注释原因参考 newMac.sh
# if [[! $(which mas) ]]; then
#   brew install mas
# fi
# if [[ $(which mas) ]]; then
#   echo -e "\033[36m >>>>>>>>>>>>>> updating App Store <<<<<<<<<<<<<< \033[0m"
#   mas outdated
#   mas upgrade
# fi

echo -e "\033[36m >>>>>>>>>>>>>> 全部更新已完成 <<<<<<<<<<<<<< \033[0m"

