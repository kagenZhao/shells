#!/usr/bin/env bash

source "`dirname $0`/tools.sh"

echo -e -n "\033[36m请输入管理员密码:\033[m"
read -s INPUT_SUDO_PASSWORD
echo
echo ${INPUT_SUDO_PASSWORD} | sudo -S -v >/dev/null 2>&1;
echo -e "\033[36m已输入管理员密码\033[m"

INPUT_PROXY_MODE='Y'
INPUT_PROXY_ADDRESS="http://127.0.0.1:1087"
IP_ADDRESS_REG='^(http\:\/\/|https\:\/\/)?((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\:([1-9][0-9]{0,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$'

function openProxy() {
  if [[ ${INPUT_PROXY_MODE} != "Y" ]]; then
    return
  fi
  tools_openProxy ${INPUT_PROXY_ADDRESS}
}

function closeProxy() {
  if [[ ${INPUT_PROXY_MODE} != "Y" ]]; then
    return
  fi
  tools_closeProxy
}

function closeProxyWithLog() {
  if [[ ${INPUT_PROXY_MODE} != "Y" ]]; then
    return
  fi
  closeProxy
  echo -e "\033[36m>>>>>>>>>>>>>> 成功关闭全局代理<<<<<<<<<<<<<<\033[0m"
}

function openProxyWithLog() {
  if [[ ${INPUT_PROXY_MODE} != "Y" ]]; then
    return
  fi
  openProxy
  echo -e "\033[36m>>>>>>>>>>>>>> 成功开启全局代理<<<<<<<<<<<<<<\033[0m"
}


function getProxyAddress() {
  echo -e -n "\033[36m请输入正确的HTTP代理IP及端口(只支持IP,默认为:127.0.0.1:1087):\033[m"
  read INPUT_PROXY_ADDRESS
  if [ ! ${INPUT_PROXY_ADDRESS} ]; then
    INPUT_PROXY_ADDRESS="http://127.0.0.1:1087"
  elif [[ "$INPUT_PROXY_ADDRESS" =~ $IP_ADDRESS_REG ]]; then
    return
  else
    echo -e "\033[36m请输入正确的代理地址\033[m"
    getProxyAddress
  fi
}

function startProxy() {
  echo -e -n "\033[36m是否开启代理模式?(y/n,默认开启):\033[m"
  read INPUT_PROXY_MODE
  INPUT_PROXY_MODE=$(echo ${INPUT_PROXY_MODE} | tr 'a-z' 'A-Z')
  if [ ! ${INPUT_PROXY_MODE} ]; then
    INPUT_PROXY_MODE="Y"
  elif [ ${INPUT_PROXY_MODE} == "Y" -o ${INPUT_PROXY_MODE} == "YES" ]; then
    INPUT_PROXY_MODE="Y"
  elif [ ${INPUT_PROXY_MODE} == "N" -o ${INPUT_PROXY_MODE} == "NO" ]; then
    INPUT_PROXY_MODE="N"
  fi
  if [[ ${INPUT_PROXY_MODE} == "Y" ]]; then
    echo -e "\033[36m已选择代理模式\033[m"
    getProxyAddress
    echo -e "\033[36m代理地址为:${INPUT_PROXY_ADDRESS}\033[m"
    openProxyWithLog
  elif [[ ${INPUT_PROXY_MODE} == "N" ]]; then
    echo -e "\033[36m已选择非代理模式\033[m"
    return
  else
    echo -e "\033[36m请输入 y(YES) or n(NO)\033[m"
    startProxy
  fi
}

startProxy

if [[ -d "${ZSH}" ]]; then
  echo -e "\033[36m>>>>>>>>>>>>>> oh my zsh updating <<<<<<<<<<<<<<\033[0m"
  env ZSH=${ZSH} sh ${ZSH}/tools/upgrade.sh
fi

if [[ $(which brew) ]]; then
  echo -e "\033[36m>>>>>>>>>>>>>> brew updating <<<<<<<<<<<<<<\033[0m"
  brew update
  echo -e "\033[36m>>>>>>>>>>>>>> brew upgrading <<<<<<<<<<<<<<\033[0m"
  brew upgrade
  echo -e "\033[36m>>>>>>>>>>>>>> brew cask upgrading <<<<<<<<<<<<<<\033[0m"
  # brew cask upgrade --greedy
  brew upgrade --cask
  # brew cask cleanup
  brew cleanup
fi

if [[ $(which pip2) ]]; then
  echo -e "\033[36m>>>>>>>>>>>>>> pip2 upgrading <<<<<<<<<<<<<<\033[0m"
  if [[ ${INPUT_PROXY_MODE} != "Y" ]]; then
    sudo -H pip2 install --upgrade pip
    sudo -H pip2 list --outdated --format=freeze  | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip2 install -U
  else
    sudo -H pip2 install --proxy ${INPUT_PROXY_ADDRESS} --upgrade pip
    sudo -H pip2 list --outdated --format=freeze  | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip2 install --proxy ${INPUT_PROXY_ADDRESS} -U
  fi
fi

if [[ $(which pip3) ]]; then
  echo -e "\033[36m>>>>>>>>>>>>>> pip3 upgrading <<<<<<<<<<<<<<\033[0m"
  if [[ ${INPUT_PROXY_MODE} != "Y" ]]; then
    sudo -H pip3 install --upgrade --no-cache-dir pip
    sudo -H pip3 list --no-cache-dir --outdated --format=freeze  | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip3 install -U --no-cache-dir
  else
    sudo -H pip3 install --proxy ${INPUT_PROXY_ADDRESS} --upgrade --no-cache-dir pip
    sudo -H pip3 list --no-cache-dir --outdated --format=freeze  | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip3 install --proxy ${INPUT_PROXY_ADDRESS} -U --no-cache-dir
  fi
fi

if [[ $(which gem) ]]; then
  if [[ ${INPUT_PROXY_MODE} != "Y" ]]; then
    echo -e "\033[36m>>>>>>>>>>>>>> gem update <<<<<<<<<<<<<<\033[0m"
    sudo gem update --system
    sudo gem update
  else
    sudo gem update -p "${INPUT_PROXY_ADDRESS}" --system
    sudo gem update -p "${INPUT_PROXY_ADDRESS}"
  fi
  sudo gem cleanup
fi

if [[ $(which pod) ]]; then
  echo -e "\033[36m>>>>>>>>>>>>>> updating pods <<<<<<<<<<<<<<\033[0m"
  # pod repo update master
  # 忽略私有库 只为master 添加代理 私有库一般都是内网 或者 国内网络 不需要代理
  closeProxy
  pod repo | grep -Eo '^[a-zA-Z_-]+$' | grep -Eov "^master$" | xargs -n1  pod repo update
  openProxy
fi

closeProxyWithLog

## 注释原因参考 newMac.sh
# if [[! $(which mas) ]]; then
#   brew install mas
# fi
# if [[ $(which mas) ]]; then
#   echo -e "\033[36m >>>>>>>>>>>>>> updating App Store <<<<<<<<<<<<<< \033[0m"
#   mas outdated
#   mas upgrade
# fi

echo -e "\033[36m>>>>>>>>>>>>>> 全部更新已完成 <<<<<<<<<<<<<<\033[0m"
