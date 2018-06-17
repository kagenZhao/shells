#! /usr/local/bin/bash

LOGFILE="/Users/zhaoguoqing/Desktop/outputImages.log"
touch $LOGFILE

function fix_file_size_string() {
	size=$1
	size=$(echo "${size}" | awk '{ split( "B KB MB GB TB PB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } printf "%.2f %s", $1, v[s] }')
	return size
}

function read_dir() {
	OLDIFS=$IFS
	IFS=$(echo -en "\n\b")  
	for file in `ls $1`
	do 
		ALLPATH=$1"/"$file
		if [ -d $ALLPATH ]
		then 
			read_dir $ALLPATH
		else 
			extension=${file##*.}
			extension=$(echo $extension | tr 'a-z' 'A-Z')
			if [ $extension = "PNG" ]
			then
                oldSize=$(wc -c "${ALLPATH}" | awk '{print $1}')
                oldSizestr=$(fix_file_size_string oldSize)
                pngquant -f --ext .png --quality 90 $ALLPATH
                newSize=$(wc -c "${ALLPATH}" | awk '{print $1}')
                newSizestr=$(fix_file_size_string newSize)
                zipPercent=$(echo "$newSize $oldSize" | awk '{printf ("%.2f",($2-$1)/$2*100)}')
				echo "$ALLPATH -- $oldSizestr >>> $newSizestr  压缩率$zipPercent%" >> $LOGFILE
			fi
		fi
	done
	IFS=$OLDIFS			
}

read_dir $1 2>$LOGFILE
open $LOGFILE

