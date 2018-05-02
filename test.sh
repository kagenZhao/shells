#!/usr/bin/env bash


# quicklook_package=(abc)

# brew_casks=$(brew cask list)

# array_contains () {
#     local seeking=$1; shift
#     local in=1
#     for element; do
#         if [[ $element == $seeking ]]; then
#             in=0
#             echo 0
#             break
#         fi
#     done
#     return $in
# }


# for value in ${quicklook_package[@]}
# do
#   if [[ ! $(array_contains $value $brew_casks) ]]; then
#       brew cask install $value
#   fi
# done


# echo -n "please input sudo password:"
# read  INPUT_PASSWORD
# echo $INPUT_PASSWORD

# echo -n "please input sudo password:"
# read -s INPUT_SUOD_PASSWORD
# echo $INPUT_SUOD_PASSWORD | sudo -S -v
# echo -e "\033[36m >>>>>>>>>>>>>> 开启全局代理 <<<<<<<<<<<<<< \033[m"

# cd ~
# ZSH_INSTALL_PATH="$PWD/.on-my-zsh"
# echo $ZSH_INSTALL_PATH
# if [[ ! -f "$ZSH_INSTALL_PATH" ]]; then
#   echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 ZSH <<<<<<<<<<<<<< \033[0m"
# fi

# INPUT_PROXY_MODE='y'
# INPUT_PROXY_ADDRESS="127.0.0.1:1087"
# IP_ADDRESS_REG='^(http\:\/\/|https\:\/\/)?((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\:([1-9][0-9]{0,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$'
#
# function openProxy() {
#   if [[ $INPUT_PROXY_MODE != "y" ]]; then
#     return
#   fi
#   if [[ $INPUT_PROXY_ADDRESS != http* ]]; then
#     INPUT_PROXY_ADDRESS="http://$INPUT_PROXY_ADDRESS"
#   fi
#   export http_proxy=$INPUT_PROXY_ADDRESS
#   export https_proxy=$INPUT_PROXY_ADDRESS
#   export ALL_PROXY=$INPUT_PROXY_ADDRESS
#   git config --global http.proxy $INPUT_PROXY_ADDRESS
#   git config --global https.proxy $INPUT_PROXY_ADDRESS
#   echo -e "\033[36m >>>>>>>>>>>>>> 成功开启全局代理<<<<<<<<<<<<<< \033[0m"
# }
#
# function closeProxy() {
#   if [[ $INPUT_PROXY_MODE != "y" ]]; then
#     return
#   fi
#   unset http_proxy
#   unset https_proxy
#   unset ALL_PROXY
#   git config --global --unset http.proxy
#   git config --global --unset https.proxy
#   sed -i -e '/^\[http\]/d;/^\[https\]/d' ~/.gitconfig
#   echo -e "\033[36m >>>>>>>>>>>>>> 成功关闭全局代理<<<<<<<<<<<<<< \033[0m"
# }
#
#
# function getProxyAddress() {
#   echo -e -n "\033[36m请输入正确的HTTP代理IP及端口(只支持IP,默认为:127.0.0.1:1087):\033[m"
#   read INPUT_PROXY_ADDRESS
#   echo
#   if [ ! $INPUT_PROXY_ADDRESS ]; then
#     INPUT_PROXY_ADDRESS="127.0.0.1:1087"
#   elif [[ "$INPUT_PROXY_ADDRESS" =~ $IP_ADDRESS_REG ]]; then
#     return
#   else
#     getProxyAddress
#   fi
# }
#
# function startProxy() {
#   echo -e -n "\033[36m是否开启代理模式?(y/n):\033[m"
#   read INPUT_PROXY_MODE
#   echo
#   if [ $INPUT_PROXY_MODE == "y" -o $INPUT_PROXY_MODE == "yes" -o $INPUT_PROXY_MODE == "Y" -o $INPUT_PROXY_MODE == "YES" ]; then
#       INPUT_PROXY_MODE="y"
#       getProxyAddress
#       openProxy
#   elif [ $INPUT_PROXY_MODE == "n" -o $INPUT_PROXY_MODE == "no" -o $INPUT_PROXY_MODE == "N" -o $INPUT_PROXY_MODE == "NO" ]; then
#     INPUT_PROXY_MODE="n"
#     return
#   else
#     echo -e "\033[36m请输入 y(YES) or n(NO)\033[m"
#     startProxy
#   fi
# }
#
# startProxy
# closeProxy
# echo $INPUT_PROXY_MODE
# echo $INPUT_PROXY_ADDRESS


echo -e -n "\033[36m请输入管理员密码:\033[m"
read -s INPUT_SUDO_PASSWORD
echo -n $INPUT_SUOD_PASSWORD | sudo -S -v;
echo
