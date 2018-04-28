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

cd ~
ZSH_INSTALL_PATH="$PWD/.on-my-zsh"
echo $ZSH_INSTALL_PATH
if [[ ! -f "$ZSH_INSTALL_PATH" ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 ZSH <<<<<<<<<<<<<< \033[0m"
fi