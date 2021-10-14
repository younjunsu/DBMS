#!/bin/bash
# coding = utf8

function monitoring(){
	cubrid statdump -i $interval $db_name@localhost |awk -f $CUBRID/monitor/cub_shell/statdump.awk
}

function checking(){
	clear
	echo "[TTY Cecking]"
	echo "======================================================================="
	tty
	echo
	echo
	echo "======================================================================="
	echo
	echo "[PROCESS Checking]"
	echo "======================================================================="
	echo "                 STARTED TT         PID CMD"
	ps -eo lstart,tty,pid,cmd |grep cub  |grep -vE "cub_|su - cubrid|grep"
	echo
	echo 
	echo "======================================================================="
	echo
	echo "[LOG DIR Checking]"
	echo "======================================================================="
	echo "KB"
	du -sk /NCIS/CUBRID/monitor/cub_log/CUB*
	echo
	echo
	

}


case $1 in
	all|ALL)
			
                	DIR_NAME=`date +CUBLOG_%Y-%m-%d_%Hh%Mm%Ss`
                	DIR_PATH=/NCIS/CUBRID/monitor/cub_log/$DIR_NAME
                	db_name=$2
                	interval=$3
                	mkdir -p $DIR_PATH
                	cubrid broker status -s $interval -f -b -t -l 1 >> $DIR_PATH/broker_status.log &
                	cubrid statdump -i $interval $db_name@localhost >> $DIR_PATH/db_status.log &
		;;
	monitor|MONITOR)
		db_name=$2
		interval=$3
		monitoring $db_name $interval
		;;
	check|CHECK)
		checking
		;;
	*)
		if [ $1 -z ] 2>/dev/null ; then
				continue 2>/dev/null
		else
			echo "ERROR >" "$1" "option not found"
			echo
		fi
			echo "< usage >"
			echo "	cub_server, cub_broker Log Collector"
			echo "		command : ./cub_junsu.sh all db_name interval(sec)"
			echo
			echo "	Real Time Monitoring"
			echo "		command : ./cub_junsu.sh monitor db_name interval(sec)"
			echo
			echo "	PROCESS CLEANER"
			echo "		command : ./cub_junsu.sh check"
			echo
		;;
esac

