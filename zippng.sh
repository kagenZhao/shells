#!/usr/bin/env bash

source "$(dirname "$0")/tools.sh"

function get_error_message() {
	case $1 in
		0 ) echo "SUCCESS" ;;
		1 ) echo "MISSING_ARGUMENT" ;;
		2 ) echo "READ_ERROR" ;;
		4 ) echo "INVALID_ARGUMENT" ;;
		15 ) echo "NOT_OVERWRITING_ERROR" ;;
		16 ) echo "CANT_WRITE_ERROR" ;;
		17 ) echo "OUT_OF_MEMORY_ERROR" ;;
		18 ) echo "WRONG_ARCHITECTURE" ;;
		24 ) echo "PNG_OUT_OF_MEMORY_ERROR" ;;
		25 ) echo "LIBPNG_FATAL_ERROR" ;;
		26 ) echo "WRONG_INPUT_COLOR_TYPE" ;;
		35 ) echo "LIBPNG_INIT_ERROR" ;;
		98 ) echo "TOO_LARGE_FILE" ;;
		99 ) echo "TOO_LOW_QUALITY" ;;
		? ) echo "未知错误" ;;
	esac
}

function read_dir() {
	local OLDIFS=$IFS
	IFS=$(echo -en "\n\b")
	local OUTPUTFILE=$2 
	local PNGCount=0
	local SUCCESSZIP=0
	local ERRORZIP=0
	local ZIPQUALITY=$3
	for file in `ls $1`
	do 
		local ALLPATH=$1"/"$file
		if [ -d "$ALLPATH" ]
		then 
			local subresult=$(read_dir "$ALLPATH" "$OUTPUTFILE" $ZIPQUALITY)
			local allCount=$(echo $subresult | cut -d '|' -f 1)
			local successCount=$(echo $subresult | cut -d '|' -f 2)
			local errorcount=$(echo $subresult | cut -d '|' -f 3)
			PNGCount=$((PNGCount+allCount))
			SUCCESSZIP=$((SUCCESSZIP+successCount))
			ERRORZIP=$((ERRORZIP+errorcount))
		else 
			local extension=${file##*.}
			extension=$(echo $extension | tr 'a-z' 'A-Z')
			if [ $extension = "PNG" ]
			then
				PNGCount=$((PNGCount+1))
                local oldSize=$(wc -c "${ALLPATH}" | awk '{print $1}')
                local oldSizestr=$(tools_echo_file_size_string $oldSize)
                pngquant -f --ext .png --quality $ZIPQUALITY "$ALLPATH" >/dev/null 2>&1
                local errorCode=$?
                if [[ $errorCode -ne 0 ]]; then
                	ERRORZIP=$((ERRORZIP+1))
                	echo "ERROR!!: '$ALLPATH', 错误码: $errorCode, 错误信息: $(get_error_message $errorCode)" >> "$OUTPUTFILE"
                else
					SUCCESSZIP=$((SUCCESSZIP+1))
					local newSize=$(wc -c "${ALLPATH}" | awk '{print $1}')
                	local newSizestr=$(tools_echo_file_size_string $newSize)
                	local zipPercent=$(echo "$newSize $oldSize" | awk '{printf ("%.2f",($2-$1)/$2*100)}')
					echo "$ALLPATH -- $oldSizestr >>> $newSizestr  压缩率$zipPercent%" >> "$OUTPUTFILE"
                fi
			fi
		fi
	done
	IFS=$OLDIFS	
	echo "$PNGCount|$SUCCESSZIP|$ERRORZIP"
}

tools_check_brew_libs_and_install "pngquant" >/dev/null 2>&1


LOGFILE="/Users/$(echo `whoami`)/Desktop/zip_png_log-$(echo `date '+%Y-%m-%d %H-%M-%S'`).log"
# touch "$LOGFILE"
INPUTFILE=""
ZIPQUALITY=100

while getopts ":i:q:l:h" opt; do
	case $opt in
		i )
			temp_var="$OPTARG"
			if [[ $temp_var =~ ^.. ]]; then
				temp_var=${temp_var/\.\.\//`PWD`\/}
			elif [[ $temp_var =~ ^. ]]; then
				temp_var=${temp_var/\.\//`PWD`\/}
			elif [[ $temp_var =~ ^~ ]];then
				temp_var=${temp_var/\~\//$HOME\/}
			fi
			INPUTFILE="$temp_var"
			;;
		q )
			ZIPQUALITY=$OPTARG
			;;
		l )
			temp_var="$OPTARG"
			if [[ $temp_var =~ ^.. ]]; then
				temp_var=${temp_var/\.\.\//`PWD`\/}
			elif [[ $temp_var =~ ^. ]]; then
				temp_var=${temp_var/\.\//`PWD`\/}
			elif [[ $temp_var =~ ^~ ]];then
				temp_var=${temp_var/\~\//$HOME\/}
			fi
			LOGFILE=$temp_var
			;;
		h )
			echo "用法:"
			echo
			echo "    $ /Path/To/script/script.sh 参数"
			echo
			echo "参数:"
			echo "    -i       图片所在路径"
			echo "    -q       图片压缩的质量, 默认100(1-100)"
			echo "    -l       日志输出文件, 可直观的查看压缩信息, 默认在 ~/Desktop/zip_png_log.log"
			echo "    -h       帮助信息"
			exit 0
			;;
		\? )
			echo "Invalid option: -$OPTARG"
			;;
	esac
done

if [[ $INPUTFILE = "" ]]; then
	echo "请输入图片所在路径"
	exit 1
fi

echo "" >> "$LOGFILE"
echo "" >> "$LOGFILE"
echo "" >> "$LOGFILE"

echo "开始压缩PNG图片: $(echo `date '+%Y-%m-%d %H:%M:%S'`)" >> "$LOGFILE"
echo "压缩路径: $INPUTFILE" >> "$LOGFILE"
echo "日志路径: $LOGFILE" >> "$LOGFILE"

zip_result=$(read_dir "$INPUTFILE" "$LOGFILE" $ZIPQUALITY)

echo "压缩PNG图片完毕: $(echo `date '+%Y-%m-%d %H:%M:%S'`), 图片数量:$(echo $zip_result | cut -d '|' -f 1), 成功:$(echo $zip_result | cut -d '|' -f 2), 失败:$(echo $zip_result | cut -d '|' -f 3)" >> "$LOGFILE"

open "$LOGFILE"

