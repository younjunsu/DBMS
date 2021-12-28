#!/bin/sh
Count=`ps -ef | grep tbsvr | grep tibero | grep -v tbsvr_WT | grep -v grep | wc -l`
if [ $Count -lt 6 ]
then
	echo "Tibero process fault"
	exit 100
else
	echo "Tibero process success"
	exit 110
fi
