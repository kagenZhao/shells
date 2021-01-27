#!/usr/bin/env bash

# create by kagen zhao 

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

function echoLog() {
	if [ $2 ]; then
		echo $1 >> $2
	else
		echo $1 >&2 
	fi
}

function read_dir() {
	local OLDIFS=$IFS
	IFS=$(echo -en "\n\b")
	local OUTPUT_FILE=$2 
	local PNG_COUNT=0
	local SUCCESS_COMPRESSION=0
	local ERROR_COMPRESSION=0
	local COMPRESSION_QUALITY=$3
	for file in `ls $1`
	do 
		local TEMP_OUTPUT_PATH=$1"/temp."$file
		local FULL_PATH=$1"/"$file
		if [ -d "$FULL_PATH" ]
		then 
			for EXCLUDE_DIR in ${EXCLUDE_PATH_DIR_LIST[@]}
			do
				if [ "$FULL_PATH" = "$EXCLUDE_DIR" ]; then
					continue 2;
				fi
			done
			local sub_result=$(read_dir "$FULL_PATH" "$OUTPUT_FILE" $COMPRESSION_QUALITY)
			local sub_count=$(echo $sub_result | cut -d '|' -f 1)
			local sub_success_count=$(echo $sub_result | cut -d '|' -f 2)
			local sub_error_count=$(echo $sub_result | cut -d '|' -f 3)
			PNG_COUNT=$((PNG_COUNT+sub_count))
			SUCCESS_COMPRESSION=$((SUCCESS_COMPRESSION+sub_success_count))
			ERROR_COMPRESSION=$((ERROR_COMPRESSION+sub_error_count))
		else 
			for EXCLUDE_FILE in ${EXCLUDE_PATH_FILE_LIST[@]}
			do
				if [ "$FULL_PATH" = "$EXCLUDE_FILE" ]; then
					continue 2;
				fi
			done
			local file_extension=${file##*.}
			file_extension=$(echo $file_extension | tr 'a-z' 'A-Z')
			if [ $file_extension = "PNG" ]
			then
				PNG_COUNT=$((PNG_COUNT+1))
                local original_size=$(wc -c "${FULL_PATH}" | awk '{print $1}')
                local original_size_str=$(tools_echo_file_size_string $original_size)
                pngquant --quality $COMPRESSION_QUALITY --output $TEMP_OUTPUT_PATH "$FULL_PATH" >/dev/null 2>&1
                local error_code=$?
                if [[ $error_code -ne 0 ]]; then
                	ERROR_COMPRESSION=$((ERROR_COMPRESSION+1))
                	echoLog "ERROR!!: '$FULL_PATH', 错误码: $error_code, 错误信息: $(get_error_message $error_code)" "$OUTPUT_FILE"
                else
					SUCCESS_COMPRESSION=$((SUCCESS_COMPRESSION+1))
					local new_size=$(wc -c "${TEMP_OUTPUT_PATH}" | awk '{print $1}')
                	local new_size_str=$(tools_echo_file_size_string $new_size)

                	local resultPercent=$(echo "$(printf "%.2f" `echo "scale=3; (${original_size}-${new_size})/${original_size}*100" | bc -q`) > 1" | bc -q)
                	if [[ $resultPercent -eq 1 ]]; then
                		mv -f $TEMP_OUTPUT_PATH $FULL_PATH
  						local compression_ratio=$(echo "$new_size $original_size" | awk '{printf ("%.2f",($2-$1)/$2*100)}')
						echoLog "$FULL_PATH -- $original_size_str >>> $new_size_str  压缩率$compression_ratio%" "$OUTPUT_FILE"
                	else  
                		rm -f $TEMP_OUTPUT_PATH
  						echoLog "$FULL_PATH -- $original_size_str >>> $original_size_str 无需压缩" "$OUTPUT_FILE"
                	fi                	
                fi
			fi
		fi
	done
	IFS=$OLDIFS	
	echo "$PNG_COUNT|$SUCCESS_COMPRESSION|$ERROR_COMPRESSION"
}

tools_check_brew_libs_and_install "pngquant" >/dev/null 2>&1


# LOG_FILE="$HOME/Desktop/png_compression_log-$(echo `date '+%Y-%m-%d %H-%M-%S'`).log"
LOG_FILE=
INPUT_DIRECTORY="$( cd "$( dirname "$0" )" && pwd )"
COMPRESSION_QUALITY=100
EXCLUDE_PATH_LIST_PARA=()
EXCLUDE_PATH_DIR_LIST=()
EXCLUDE_PATH_FILE_LIST=()

while getopts ":i:q:e:l:h" opt; do
	case $opt in
		i )
			pushd $OPTARG >/dev/null 2>&1
			RES_CODE="$?"
			if [[ $RES_CODE = 0 ]]; then
				INPUT_DIRECTORY=`PWD`
				popd >/dev/null 2>&1
			else
				echo "输入目录有误: $OPTARG"
				exit $RES_CODE
			fi
			;;
		q )
			COMPRESSION_QUALITY=$OPTARG
			;;
		e )
			EXCLUDE_PATH_LIST_PARA+=("$OPTARG")
			;;
		l )
			pushd `dirname $OPTARG` >/dev/null 2>&1
			RES_CODE="$?"
			if [[ $RES_CODE = 0 ]]; then
				LOG_FILE="`PWD`/${OPTARG##*/}"
				popd >/dev/null 2>&1
			else
				echo "log路径有误有误: $OPTARG"
				exit $RES_CODE
			fi
			;;
		h )
			echo "用法:"
			echo
			echo "    $ /Path/To/script/script.sh 参数"
			echo
			echo "参数:"
			echo "    -i       图片所在路径"
			echo "    -q       图片压缩的质量, 默认100(1-100)"
			echo "    -e       需要排除的文件夹, 相对地址"
			echo "    -l       日志输出文件, 可直观的查看压缩信息, 默认在 ~/Desktop/png_compression_log.log"
			echo "    -h       帮助信息"
			exit 0
			;;
		\? )
			echo "Invalid option: -$OPTARG"
			;;
	esac
done

if [ ${LOG_FILE} ]; then
	open "$LOG_FILE" &
fi
 
echoLog "开始压缩PNG图片: $(echo `date '+%Y-%m-%d %H:%M:%S'`)"  "$LOG_FILE"
echoLog "压缩路径: $INPUT_DIRECTORY" "$LOG_FILE"
for value in ${EXCLUDE_PATH_LIST_PARA[@]}
do 
	TEMP_PATH="$INPUT_DIRECTORY/$value"
	if [ -d "$TEMP_PATH" ]; then
		echoLog "排除目录: $TEMP_PATH" "$LOG_FILE"
		EXCLUDE_PATH_DIR_LIST+=("$TEMP_PATH")
	else
		echoLog "排除文件: $TEMP_PATH" "$LOG_FILE"
		EXCLUDE_PATH_FILE_LIST+=("$TEMP_PATH")
	fi
done
if [ ${LOG_FILE} ]; then
	echoLog "日志路径: $LOG_FILE" "$LOG_FILE"
fi

echoLog "压缩质量: $COMPRESSION_QUALITY" "$LOG_FILE"

compression_result=$(read_dir "$INPUT_DIRECTORY" "$LOG_FILE" $COMPRESSION_QUALITY)

echoLog "压缩PNG图片完毕: $(echo `date '+%Y-%m-%d %H:%M:%S'`), 图片数量:$(echo $compression_result | cut -d '|' -f 1), 成功:$(echo $compression_result | cut -d '|' -f 2), 失败:$(echo $compression_result | cut -d '|' -f 3)" "$LOG_FILE"

