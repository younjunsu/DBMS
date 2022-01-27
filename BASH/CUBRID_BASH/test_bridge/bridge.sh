#!/bin/bash
## codinge = utf-8


function monitoring(){
		#cubrid statdump -i $interval $db_name |grep query |grep -vE "OTHER STATISTICS|SERVER EXECUTION STATISTICS|KST|^$" |sed 's/=//g' |awk '{print strftime("%Y-%m-%d %T")"\t|\t"$1"\t|\t"$2}'
		cubrid statdump -i $interval $db_name |awk -f $CUBRID/share/bash_cubrid/bridge/bridge_monitor.awk |tee junsuyoun
		#cubrid statdump  $db_name |awk -f $CUBRID/share/bash_cubrid/bridge/bridge_monitor.awk
}

function checking(){
		echo "Process Checking"
		echo "JOBS"
		jobs
		echo
		echo "ps -ef"
		ps -ef |grep cubrid
		echo
		echo "END"
}


case $1 in 
	broker|BROKER)
		echo "./bridge_broker" $2 $3
		;;
	statdump|STATDUMP)
		echo "./bridge_statdump" $2 $3
		;;
	check|CHECK)
		checking
		;;
	monitor|MONITOR)
		db_name=$2
		interval=$3
		monitoring $db_name $interval
		;;
		
	*)
		if [ $1 -z ]  2>/dev/null ; then
			continue 2>/dev/null
		else
			echo "ERROR >" "$1" "option not found"
			echo
		fi
			echo "< usage >"
			echo "	cub_server STATDUMP Monitoring"
			echo "		command: $ ./bridge.sh statdump db_name interval(sec)"
			echo
			echo "	cub_broker Monitoring"
			echo "		command: $ ./bridge.sh broker broker_name interval(sec)"
			echo
			echo " 	Real Time Monitoring"
			echo "		command: $ ./bridge.sh monitor db_name interval(sec)"
			echo	
			echo "	Process Checking"
			echo "		command: $ ./bridge check"
		;;
esac
