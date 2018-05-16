#!/usr/bin/env zsh

LOCAL=$(ifconfig | grep -A 1 "en" | grep broadcast | cut -d " " -f 2)
EXTERNAL=$(curl ip.cn | grep -i "ip" | cut -d " " -f 2 | cut -d "：" -f 2)

cat <<EOF
<?xml version="1.0"?>
<items>
EOF

LOCAL_RESULT_COUNT=1
LOCAL_ARR=($(echo $LOCAL | tr "\\n" $IFS))
for value in ${LOCAL_ARR[@]};
do
cat <<EOF
<item uid="localip$LOCAL_RESULT_COUNT" arg="$value">
<title>Local IP$LOCAL_RESULT_COUNT: $value</title>
<subtitle>Press Enter to paste, or Cmd+C to copy</subtitle>
<icon>icon.png</icon>
</item>
EOF
    LOCAL_RESULT_COUNT=`expr $LOCAL_RESULT_COUNT + 1`
done

cat <<EOF
<item uid="externalip" arg="$EXTERNAL">
<title>External IP: $EXTERNAL</title>
<subtitle>Press Enter to paste, or Cmd+C to copy</subtitle>
<icon>icon.png</icon>
</item>
</items>
EOF
