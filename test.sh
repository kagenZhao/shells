#!/usr/bin/env bash
function startProxy() {
  echo -e -n "\033[36m是否开启代理模式?(y/n):\033[m"
  read INPUT_PROXY_MODE
  echo $INPUT_PROXY_MODE
  INPUT_PROXY_MODE=$(echo $INPUT_PROXY_MODE | tr 'a-z' 'A-Z')
  if [ $INPUT_PROXY_MODE == "Y" -o $INPUT_PROXY_MODE == "YES" ]; then
      INPUT_PROXY_MODE="Y"
  elif [ $INPUT_PROXY_MODE == "N" -o $INPUT_PROXY_MODE == "NO" ]; then
    INPUT_PROXY_MODE="N"
    return
  else
    echo -e "\033[36m请输入 y(YES) or n(NO)\033[m"
    startProxy
  fi
}
startProxy
