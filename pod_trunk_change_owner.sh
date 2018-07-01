#!/usr/bin/env bash


if [[ ! $(which pod) ]]; then
  echo "Please install Cocoapods!"
  exist 1
fi

POD_VERSION=$(pod --version | sed 's/\.//g')


if [[ "$POD_VERSION" -lt "33" ]]; then
  echo "Please upgrade Cocoapods!"	
  exist 1
fi


FROM_EMAIL=$0
FROM_USER=$1
TO_EMAIL=$2
TO_USER=$3

pod trunk register $FROM_EMAIL $FROM_USER
echo "Please verify, if you completed it, Enter for continue:"
read Enter
POD_TRUNK_LIST_STRING=$(pod trunk me | grep -Ev 'IP:\s' | grep -E '^\s\s\s' | tr -d '    -' | tr '\n' ' ')
POD_TRUNK_COUNT=1
while [[ 1 ]]; do
	POD_TRUNK_ITEM=$($(echo $POD_TRUNK_LIST_STRING | cut -d ' ' -f $POD_TRUNK_COUNT | tr -d '[:space:]'))
	if [[ -z $POD_TRUNK_ITEM ]]; then
		break
	fi
	if [[ -n $POD_TRUNK_ITEM ]]; then
		pod trunk add-owner $POD_TRUNK_ITEM $TO_EMAIL
	fi
done


pod trunk register $TO_EMAIL $TO_USER
echo -n "Please verify, if you completed it, Enter for continue:"
read -s Enter
echo
POD_TRUNK_LIST_STRING=$(pod trunk me | grep -Ev 'IP:\s' | grep -E '^\s\s\s' | tr -d '    -' | tr '\n' ' ')
POD_TRUNK_COUNT=1
while [[ 1 ]]; do
	POD_TRUNK_ITEM=$($(echo $POD_TRUNK_LIST_STRING | cut -d ' ' -f $POD_TRUNK_COUNT | tr -d '[:space:]'))
	if [[ -z $POD_TRUNK_ITEM ]]; then
		break
	fi
	if [[ -n $POD_TRUNK_ITEM ]]; then
		pod trunk remove-owner $POD_TRUNK_ITEM $FROM_EMAIL
	fi
done
