#!/usr/bin/env bash

source ./tools.sh

function read_dir() {
	OLDIFS=$IFS
	IFS=$(echo -en "\n\b")
	OUTPUTFILE=$2 
	PNGCount=0
	SUCCESSZIP=0
	ERRORZIP=0
	ZIPQUALITY=$3
	for file in `ls $1`
	do 
		ALLPATH=$1"/"$file
		if [ -d $ALLPATH ]
		then 
			subresult=$(read_dir $ALLPATH)
			allCount=$(echo $subresult | cut -d '|' -f 1)
			successCount=$(echo $subresult | cut -d '|' -f 2)
			errorcount=$(echo $subresult | cut -d '|' -f 3)
			PNGCount=$((PNGCount+allCount))
			SUCCESSZIP=$((SUCCESSZIP+successCount))
			ERRORZIP=$((ERRORZIP+errorcount))
		else 
			extension=${file##*.}
			extension=$(echo $extension | tr 'a-z' 'A-Z')
			if [ $extension = "PNG" ]
			then
				PNGCount=$((PNGCount+1))
                oldSize=$(wc -c "${ALLPATH}" | awk '{print $1}')
                oldSizestr=$(tools_echo_file_size_string $oldSize)
                pngquant -f --ext .png --quality $ZIPQUALITY $ALLPATH
                echo $?
                if [[ $? -ne 0 ]]; then
                	ERRORZIP=$((ERRORZIP+1))
                else
                	newSize=$(wc -c "${ALLPATH}" | awk '{print $1}')
                	newSizestr=$(tools_echo_file_size_string $newSize)
                	zipPercent=$(echo "$newSize $oldSize" | awk '{printf ("%.2f",($2-$1)/$2*100)}')
					echo "$ALLPATH -- $oldSizestr >>> $newSizestr  压缩率$zipPercent%" >> $OUTPUTFILE
					SUCCESSZIP=$((SUCCESSZIP+1))
                fi
			fi
		fi
	done
	IFS=$OLDIFS	
	echo "$PNGCount|$SUCCESSZIP|$ERRORZIP"
}

tools_check_brew_libs_and_install "pngquant" >/dev/null 2>&1


LOGFILE="/Users/$(echo `whoami`)/Desktop/outputImages.log"
INPUTFILE=""
ZIPQUALITY=90

while getopts ":i:q:l:h" opt; do
	case $opt in
		i )
			temp_var="$OPTARG"
			if [[ $temp_var =~ ^.. ]]; then
				temp_var=$(echo $temp_var | sed "s~^..~$(pwd)~g")
			elif [[ $temp_var =~ ^. ]]; then
				temp_var=$(echo $temp_var | sed "s~^.~$(pwd)~g")
			fi
			INPUTFILE="$temp_var"
			;;
		q )
			ZIPQUALITY=$OPTARG
			;;
		l )
			temp_var="$OPTARG"
			temp_var="$OPTARG"
			if [[ $temp_var =~ ^.. ]]; then
				temp_var=$(echo $temp_var | sed "s~^..~$(pwd)~g")
			elif [[ $temp_var =~ ^. ]]; then
				temp_var=$(echo $temp_var | sed "s~^.~$(pwd)~g")
			fi
			LOGFILE=$OPTARG
			;;
		h )
			echo "用法:"
			echo
			echo "    $ /Path/To/script/script.sh 参数"
			echo
			echo "参数:"
			echo "    -i       图片所在路径"
			echo "    -q       图片压缩的质量, 默认90(1-100)"
			echo "    -l       日志输出文件, 可直观的查看压缩信息, 默认在 ~/Desktop/outputImages.log"
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

echo "" >> $LOGFILE
echo "" >> $LOGFILE
echo "" >> $LOGFILE

echo "开始压缩PNG图片: $(echo `date '+%Y-%m-%d %H:%M:%S'`)" >> $LOGFILE
echo "压缩路径: $INPUTFILE" >> $LOGFILE
echo "日志路径: $LOGFILE" >> $LOGFILE

zip_result=$(read_dir $1 $LOGFILE $ZIPQUALITY)

echo "压缩PNG图片完毕: $(echo `date '+%Y-%m-%d %H:%M:%S'`), 图片数量:$(echo $zip_result | cut -d '|' -f 1), 成功:$(echo $zip_result | cut -d '|' -f 2), 失败:$(echo $zip_result | cut -d '|' -f 3)" >> $LOGFILE

open $LOGFILE

