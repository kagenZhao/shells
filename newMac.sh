#!/usr/bin/env bash

_SHELL_FILE_PATH=`dirname $0`

source "$_SHELL_FILE_PATH/tools.sh"

echo -n "please input sudo password:"
read -s INPUT_SUDO_PASSWORD
echo
echo ${INPUT_SUDO_PASSWORD} | sudo -S -v
echo

XCODE_PATH="/Applications/Xcode.app"
if [[ ! -d "$XCODE_PATH" ]]; then
  echo "先去安装Xcode啊 大哥!!!!"
  exit 1
fi
 echo -e "\033[36m >>>>>>>>>>>>>> XCode 已安装 <<<<<<<<<<<<<< \033[0m"

cd ~

COMMANDLINETOOLS_PATH='/Library/Developer/CommandLineTools'
if [[ ! -d "$COMMANDLINETOOLS_PATH" ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> 你需要安装 CommandlineTools 才能进行以下操作 <<<<<<<<<<<<<< \033[0m"
  xcode-select --install >/dev/null 2>&1
  exit 1
fi

echo -e "\033[36m >>>>>>>>>>>>>> xcode-select 已安装 <<<<<<<<<<<<<< \033[0m"


if [[ ! $(which brew) ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 Homebrew <<<<<<<<<<<<<< \033[0m"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo -e "\033[36m >>>>>>>>>>>>>> Homebrew 已安装 <<<<<<<<<<<<<< \033[0m"


HOMEBREW_INSTALL_PATH="/usr/local/share/"
if [[ ! -x "$HOMEBREW_INSTALL_PATH" ]]; then
    echo -e "\033[36m >>>>>>>>>>>>>> 正在配置Homebrew权限 <<<<<<<<<<<<<< \033[0m"
    sudo chown -R $(whoami) $(brew --prefix)/*
fi

echo -e "\033[36m >>>>>>>>>>>>>> Homebrew 权限设置完毕 <<<<<<<<<<<<<< \033[0m"

echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 Homebrew Services <<<<<<<<<<<<<< \033[0m"
brew tap homebrew/services
echo -e "\033[36m >>>>>>>>>>>>>> Homebrew Services 设置完毕 <<<<<<<<<<<<<< \033[0m"


BREW_WILL_INSTALLS=(zsh git wget python python@2 mtr ruby carthage sqlite node watchman openssl curl flow mas make cmake gcc chisel zsh-syntax-highlighting zsh-autosuggestions ngxin mysql go)
BREW_IS_INSTALLED=$(brew list)

for value in ${BREW_WILL_INSTALLS[@]}
do
  if [[ ! $(tools_array_contains ${value} ${BREW_IS_INSTALLED}) ]]; then
      echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 ${value} <<<<<<<<<<<<<< \033[0m"
      brew install ${value}
  fi
  echo -e "\033[36m >>>>>>>>>>>>>> $value 已安装 <<<<<<<<<<<<<< \033[0m"
done

LLDBINIT_PATH="~/.lldbinit"
if [[ ! -d ${LLDBINIT_PATH} ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> 正在配置 chisel lldbinit 文件 <<<<<<<<<<<<<< \033[0m"
  echo "command script import /usr/local/opt/chisel/libexec/fblldb.py" > ~/.lldbinit
fi

echo -e "\033[36m >>>>>>>>>>>>>> lldbinit 设置完毕 <<<<<<<<<<<<<< \033[0m"


if [[ ! $(which pod) ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 Cocoapods <<<<<<<<<<<<<< \033[0m"
  sudo /usr/local/bin/gem update --system
  sudo /usr/local/bin/gem install cocoapods
fi
echo -e "\033[36m >>>>>>>>>>>>>> Cocoapods 已安装 <<<<<<<<<<<<<< \033[0m"


# 配置iTerm2 
curl -L "https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh" | bash
sudo cp "$_SHELL_FILE_PATH/com.googlecode.iterm2.plist.backup" "$HOME/Library/Preferences/com.googlecode.iterm2.plist"

if [[ ! -d "$ZSH" ]]; then
    echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 ZSH <<<<<<<<<<<<<< \033[0m"
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    export ZSH=$HOME/.oh-my-zsh
    export ZSH_CUSTOM=$ZSH/custom
    git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    sudo cp "$_SHELL_FILE_PATH/zshrc-backup" "$HOME/.zshrc"
    source "$HOME/.zshrc"
fi
echo -e "\033[36m >>>>>>>>>>>>>> ZSH 已安装 <<<<<<<<<<<<<< \033[0m"


ls ~/Library/Fonts | grep 'Powerline' >/dev/null 2>&1
if [[ $? = 1 ]]; then
  echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 Powerline <<<<<<<<<<<<<< \033[0m"
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
  cd ..
  rm -rf font
  cd ~
fi
echo -e "\033[36m >>>>>>>>>>>>>> Powerline 已安装 <<<<<<<<<<<<<< \033[0m"


# 配置Alfred

# 统一走 zshrc-backup
# ZSH_SYNTAX_HIGHLIGHTING_PATH="/usr/local/share/zsh-syntax-highlighting/"
# if [[ ! -d "$ZSH_SYNTAX_HIGHLIGHTING_PATH" ]]; then
#     echo -e "\033[36m >>>>>>>>>>>>>> 开始安装语法高亮 <<<<<<<<<<<<<< \033[0m"
#     # 然后要加几行文字到 ~/.zshrc中
#     local ZSH_SYNTAX_HIGHLIGHTING_TEXT="
#     # 为 zsh 配置语法高亮
#     # If you receive \"highlighters directory not found\" error message,
#     # you may need to add the following to your .zshenv:
#     #   export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters
#     source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#     "
#     echo ZSH_SYNTAX_HIGHLIGHTING_TEXT >> ~/.zshrc
# fi

# echo -e "\033[36m >>>>>>>>>>>>>> 已配置语法高亮 <<<<<<<<<<<<<< \033[0m"


# if [[ ! $(which nginx) ]]; then
#   echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 nginx <<<<<<<<<<<<<< \033[0m"
#   brew install nginx
#   # plutil 可以修改plist 再 mysql 和 nginx 添加自启动的时候回用到
#   local NGINX_BREW_PLIST_PATH=$(ls /usr/local/opt/nginx/*.plist)
#   sudo cp ${NGINX_BREW_PLIST_PATH} /Library/LaunchDaemons
#   local NGINX_LAUNCH_PLIST_PATH="/Library/LaunchDaemons/$NGINX_BREW_PLIST_PATH"
#   sudo plutil -remove ProgramArguments ${NGINX_LAUNCH_PLIST_PATH}
#   sudo plutil -insert ProgramArguments -json "[]" ${NGINX_LAUNCH_PLIST_PATH}
#   sudo plutil -insert ProgramArguments.0 -string "/usr/local/opt/nginx/bin/nginx" ${NGINX_LAUNCH_PLIST_PATH}
#   sudo launchctl load -w ${NGINX_LAUNCH_PLIST_PATH}
# fi
brew services start nginx
# echo -e "\033[36m >>>>>>>>>>>>>> nginx 已安装 并自启动 <<<<<<<<<<<<<< \033[0m"


# if [[ ! $(which mysql) ]]; then
#   echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 mysql <<<<<<<<<<<<<< \033[0m"
#   brew install mysql
#   # 后续操作 https://gist.github.com/nrollr/3f57fc15ded7dddddcc4e82fe137b58e
#   ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
#   launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
# fi
brew services start mysql
# echo -e "\033[36m >>>>>>>>>>>>>> mysql 已安装 并自启动 <<<<<<<<<<<<<< \033[0m"

# qlimagesize 呗干掉了  需要自己编译
QUICKLOOK_PACKAGE=(suspicious-package qlmarkdown quicklook-json quicklookase webpquicklook qlcolorcode qlstephen quicklook-pat qlvideo quicklookapk provisionql)
CASK_WILL_INSTALLS=(iina switchhosts betterzip qq iina fork iterm2 sublime-text atom dash cleanmymac alfred bartender filezilla google-chrome istat-menus youdaonote youdaodict shadowsocksx-ng cheatsheet postman wireshark baidunetdisk vmware-fusion kaleidoscope coconutbattery near-lock omnigraffle jetbrains-toolbox android-studio virtualbox qsync-client qfinder-pro thunder)
CASK_FRAMEWORKS=(java docker)
BREW_CASK_IS_INSTALLED=$(brew cask list)

for value in ${QUICKLOOK_PACKAGE[@]}
do
  if [[ ! $(tools_array_contains ${value} ${BREW_CASK_IS_INSTALLED}) ]]; then
      echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 $value <<<<<<<<<<<<<< \033[0m"
      brew cask install ${value}
  fi
    echo -e "\033[36m >>>>>>>>>>>>>> $value 已安装 <<<<<<<<<<<<<< \033[0m"

done

for value in ${CASK_WILL_INSTALLS[@]}
do
  if [[ ! $(tools_array_contains ${value} ${BREW_CASK_IS_INSTALLED}) ]]; then
      echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 $value <<<<<<<<<<<<<< \033[0m"
      brew cask install ${value}
  fi
    echo -e "\033[36m >>>>>>>>>>>>>> $value 已安装 <<<<<<<<<<<<<< \033[0m"

done


for value in ${CASK_FRAMEWORKS[@]}
do
  if [[ ! $(tools_array_contains ${value} ${BREW_CASK_IS_INSTALLED}) ]]; then
      echo -e "\033[36m >>>>>>>>>>>>>> 开始安装 $value <<<<<<<<<<<<<< \033[0m"
      brew cask install ${value}
  fi
    echo -e "\033[36m >>>>>>>>>>>>>> $value 已安装 <<<<<<<<<<<<<< \033[0m"
done



# 下载app软件  后续需要用户自行安装
# charles 破解

# appstore
# mas 在 mac high sierra 中 登录api 已经被删除 导致不可用
# 时刻关注 mas 最新进展 https://github.com/mas-cli/mas
# 将来mas 可以使用的时候 放到 第一步 xcode 下载那里
# app_store_apps=(WeChat Magnet 1Password Theine Irvue)
# app_store_apps_exist=$(mas list | cut -d ' ' -f 2)
# for value in ${app_store_apps[@]}
# do
#   if [[ ! $(tools_array_contains $value $app_store_apps_exist) ]]; then
#     value_number=$(mas search $value | grep -Eo "^([0-9]+)\s$value\s\([0-9\.]+\)" | cut -d ' ' -f 1)
#     mas install $value_number
#   fi
# done
