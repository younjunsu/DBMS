#!/bin/bash

#######################################################################
#              CUBRID Inspect Script 
#               - Create by CUBRID Co.,Ltd.
#
#######################################################################

############################ CUBRID environment variables. Start
function fn_env(){
ENV_NODAT=`ls ~/cubrid.sh 2>/dev/null`
ENV_DAT=`ls ~/.cubrid.sh  2>/dev/null`

	if [ $ENV_DAT -z ] 2>/dev/null; then
		if [ $ENV_NODAT -z ] 2>/dev/null; then
			echo "Need to check CUBRID environment variables."
		else
			. ~/cubrid.sh
		fi
	else
		. ~/.cubrid.sh
	fi
}

############################ CUBRID environment variables. End


###################################### Function List Start.

############### STEP_01. Default Platform Checking
function step_01(){
	echo "[STEP_01. Default Platform Checking]"
	echo "********************************************************************" 

	echo "--------------------------------------------------------------------" 
	echo "@ Glibc" 
	echo "> `rpm -q glibc`" 
	echo "--------------------------------------------------------------------"
	echo "@ Curses" 
	echo "> `rpm -q ncurses`" 
	echo "--------------------------------------------------------------------" 
	echo "@ Gcrypt "
	echo "> `rpm -q libgcrypt`"
	echo "--------------------------------------------------------------------"
	echo "@ Stdc++"
	echo "> `rpm -q libstdc++`"
	echo "--------------------------------------------------------------------"
}

############### STEP_02. Version Checking
function step_02(){
	echo "[STEP_02. Version Checking]"
	echo "********************************************************************"
	##Cubrid Version
	echo "--------------------------------------------------------------------"
	echo "@ CUBRID Version :"
	cubrid_rel
	

	## OS Version
	echo "--------------------------------------------------------------------" 
	echo "@ OS Version : " 
	cat /etc/*-release | uniq 2>/dev/null 
	echo 

	## Kernel Version
	echo "--------------------------------------------------------------------" 
	echo "@ Kernel Version : " 
	uname -r 
	echo 

	## JDK or JRE Version
	echo "--------------------------------------------------------------------" 
	echo "@ JDK or JRE Version : "
	java_ver=`rpm -qa | grep java 2>/dev/null`
	
	if [ $java_ver -z ] 2>/dev/null ; then
		echo "JDK or JRE None"
	else
		echo "$java_ver"
	fi
	echo "--------------------------------------------------------------------"
}

############### STEP_03. CUBRID DBMS Service Checking
function step_03(){
	echo "[STEP_03. CUBRID DBMS Service Checking]"
	echo "********************************************************************"
	master_check=`ps -ef |grep cub_master |awk '{print $8}'|grep -v "grep" `

	if [ -n master_check ] ; then
		echo "@ cubrid master status"
		echo "++ cubrid master is running."
	else
		echo "@ cubrid master status"
		echo "++ cubrid manager server is not running."
	fi
	echo
	echo "@ cubrid server status"
	cubrid server status|sort |grep -v "@ cubrid server" 2>/dev/null
	echo

	echo "@ Offline DB Name : "
	DB_ON_LIST_RES=(`cubrid server status |grep -vE "cubrid server|cubrid master"|awk '{print $2}'  |sort`)
	DB_TOTAL_LIST_RES=(`cm_admin listdb |awk '{print $2}' |sort`)
	
	DB_OFF_LIST_RES=${DB_TOTAL_LIST_RES[@]}
	for((IMSI_NUM_01=0;IMSI_NUM_01<${#DB_ON_LIST_RES[@]};IMSI_NUM_01++))
		do
					DB_OFF_LIST_RES=(`echo ${DB_OFF_LIST_RES[@]} |sed "s/${DB_ON_LIST_RES[IMSI_NUM_01]}//g"`)
					
		done
	echo ${DB_OFF_LIST_RES[@]}
	

	echo

	echo "@ cubrid broker status"
	cubrid broker status -b|grep -v "@ cubrid broker status" 2>/dev/null
	echo

	cubrid manager status 2>/dev/null
	echo
	echo "@ cubrid heartbeat list"
	cubrid hb status |grep -v "@ cubrid heartbeat list" 2>/dev/null
	echo
}

############### STEP_04. Linux Partitions Size Checking
function step_04(){
	echo "[STEP_04. Linux Partitions Size Checking]"
	echo "********************************************************************"
	df -h 2>/dev/null
}

############### STEP_05. DB Volumes Size Checking
function step_05(){
	echo "[STEP_05. DB Volumes Size Checking]"
	echo "********************************************************************"

	echo "@ DB Count : `cubrid server status| grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."|wc -l 2>/dev/null`" 
	echo 

	space_db=(`cubrid server status|grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."| awk '{print $2}'|sort 2>/dev/null`)
	echo "--------------------------------------------------------------------" 
	
	for((i=0;i<${#space_db[@]};i++)); do
		echo "> DB Name : ${space_db[i]}";
		cubrid spacedb -s ${space_db[i]}@localhost 2>/dev/null
		echo "--------------------------------------------------------------------" 
		echo
	done 
}

############### STEP_06. CUBRID DBMS Backup Checking
function step_06(){
	echo "[STEP_06. CUBRID DBMS Backup Checking]"
	echo "********************************************************************"
	
	db_path=(`cat $CUBRID/databases/databases.txt |grep -v "#db-name"|awk '{print $4}'`)
	db_name=(`cat $CUBRID/databases/databases.txt |grep -v "#db-name"|awk '{print $1}'`)
	y=0

	for((i=0;i<${#db_path[@]};i++));do
		ls_bkvinf=`ls -lrt $db_path/*bkvinf  2>/dev/null`

		if [ -e ${db_path[i]}/*bkvinf ] ; then
			echo "@ ${db_name[y]}"
			bkvinf_path=`cat ${db_path[i]}/*bkvinf|awk '{print $3}' 2>/dev/null`
			bk_file=`ls -lrth $bkvinf_path  2>/dev/null`
			
			if [ $bk_file -z ] 2>/dev/null ; then
				ls -lrth ${db_path[i]}/*bkvinf 2>/dev/null
				echo "Backup File None"	
			else
				ls -lrth ${db_path[i]}/*bkvinf 2>/dev/null
				ls -lrth $bkvinf_path  2>/dev/null
			fi
			echo
		else
			echo "@ ${db_name[y]}"
			ls -lrth ${db_path[i]}/*bkvinf 2>/dev/null
			echo "Backup File None"
			echo
		fi

	y=$(($y+1))

	done
}

############### STEP_07. CUBRID DBMS HA Sync Checking
function step_07(){
	echo "[STEP_07. CUBRID DBMS HA Sync Checking]" 
	echo "********************************************************************"
	echo "@ HA DB Count : `cubrid server status| grep  "HA"|grep -v "++ cubrid master is not running."|wc -l`" 
	echo "@ cubrid heartbeat list"
	
	cubrid hb status |grep -v "@ cubrid heartbeat list" 2>/dev/null

	ha_db=(`cubrid hb status|grep "Server "|awk '{print $2}'|sort 2>/dev/null`)
	host_nm=`hostname`
	remote_nm=`cubrid hb status|grep Node |grep -v "$host_nm"|awk '{print $2}' 2>/dev/null`

	echo "--------------------------------------------------------------------"
	
	for((i=0;i<${#ha_db[@]};i++));do
		echo "@ DB Name : ${ha_db[i]}"
		copy_path=`cubrid hb status |grep ${ha_db[i]}|grep -v "Copy"|grep -v "Server "|awk '{print $2}'|sed 's/@localhost/ /g'|awk '{print $2}'|sed 's/:/ /g' 2>/dev/null`
		cubrid applyinfo -a -r $remote_nm -L $copy_path ${ha_db[i]}  2>/dev/null
		echo "--------------------------------------------------------------------"
	done
	
	echo
}

############### STEP_08. CUBRID DBMS Active or Archives Log Checking
function step_08(){
	echo "[STEP_08. CUBRID DBMS Active or Archives Log Checking]"
	echo "********************************************************************"

	lists_db=(`cat $CUBRID/databases/databases.txt|grep -v "#db-name"|awk '{print $1}'|sort `)
	echo "--------------------------------------------------------------------"
	for((i=0;i<${#lists_db[@]};i++));do
		echo "@ DB Name : ${lists_db[i]}"

		echo "> Parameter Checking"
		param_check=`cubrid paramdump ${lists_db[i]}@localhost 2>/dev/null |grep -E "log_max_archives=|force_remove_log_archives=" `
		
		if [ $param_check -z ] 2>/dev/null ; then
			echo "Databases Not Running"
		else
			echo "$param_check"
		fi
			
		ac_count=`cubrid paramdump ${lists_db[i]}@localhost 2>/dev/null |grep log_max_archives=|grep -v "ha_copy_log_max_archives"|sed 's/log_max_archives=/ /g'`
		ac_count=$(($ac_count+5))
		lists_log=`cat $CUBRID/databases/databases.txt |grep ${lists_db[i]} |awk '{print $4}'`
		echo
		echo "> Active or Archive Log"
		ls -lrth $lists_log |grep lgar|tail -$ac_count
		echo

		copy_check=`cat $CUBRID/conf/cubrid_ha.conf |grep ha_copy_log_base`
		ha_check=`cat $CUBRID/conf/cubrid_ha.conf|grep ${lists_db[i]} `

			if [ $copy_check -z ] 2>/dev/null ; then
				copy_dir=`ls $CUBRID/databases |grep ${lists_db[i]} `
						if [ $copy_dir -z -a $ha_check -z ] 2>/dev/null ; then
								echo "> Copylogdb Checking"
								echo "Not HA"
								echo
						else
						echo "> Copylogdb Checking : $CUBRID/databases/${lists_db[i]}*"
						ls -lrth $CUBRID/databases/${lists_db[i]}*
						fi
			else
				copy_base=`cat $CUBRID/conf/cubrid_ha.conf |grep ha_copy_log_base|sed 's/ha_copy_log_base=/ /g'`
						if [ $ha_check -z ] 2>/dev/null ; then
						echo "> Copylogdb Checking"
						echo "Not HA"
						echo
						else
						echo "> Copylogdb Checking : $copy_base/${lists_db[i]}*"
						ls -lrth $copy_base/${lists_db[i]}*
						fi
			fi
			echo "--------------------------------------------------------------------"
		done
}

############### STEP_09. DB Parameters Checking
function step_09(){
	echo "[STEP_09. DB Parameters Checking]"
	echo "********************************************************************"
	echo "--------------------------------------------------------------------" 
	echo "@ cubrid.conf"  
	cat $CUBRID/conf/cubrid.conf |grep -v "#"|grep -v  "^$" 
	echo "--------------------------------------------------------------------" 
	echo "@ Online DB Count : `cubrid server status| grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."|wc -l`" 
	echo 

	lists_db=(`cubrid server status|grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."| awk '{print $2}'|sort`)
	echo "--------------------------------------------------------------------" 
	for((i=0;i<${#lists_db[@]};i++)); do
		echo "@ DB Name : ${lists_db[i]}";
		cubrid paramdump ${lists_db[i]}@localhost|grep -E "data_buffer_size=|max_clients=|java_stored_procedure=|isolation_level=|lock_escalation=|force_remove_log_archives=|log_max_archives=|ha_mode=|ha_copy_sync_mode=|ha_copy_log_base="
		echo "--------------------------------------------------------------------"
		echo
	done 
}

############### STEP_10. Broker Parameters Check
function step_10(){
	echo "[STEP_10. Broker Parameters Check]" 
	echo "********************************************************************"

	cat $CUBRID/conf/cubrid_broker.conf|grep -A30 "%" 
}

############### STEP_11. Broker Status Checking
function step_11(){
	echo "[STEP_11. Broker Status Checking]" 
	echo "********************************************************************"
	cubrid broker status -f -b 
	echo 
}

############### STEP_12. Recent ERR Log Checking
function step_12(){
	echo "[STEP_12. Recent ERR Log Checking]" 
	echo "********************************************************************"
	lists_db=(`cat $CUBRID/databases/databases.txt|grep -v "#db-name" |awk '{print $1}' |sort`)

		
	
	old_new_diff=30
	echo "--------------------------------------------------------------------"	

	master_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$old_new_diff -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "master" 2>/dev/null `
	copy_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$old_new_diff -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "copylog" 2>/dev/null `
	apply_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$old_new_diff -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "applylog" 2>/dev/null `
	backup_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$old_new_diff -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "backupdb" 2>/dev/null `
	echo "@ Master.err"	
	if [ $master_err -z ] 2>/dev/null; then
		echo "> Master.err None"	
	else
	echo "$master_err"	
	fi
	echo "--------------------------------------------------------------------"	
	echo "@ Copylogdb.err"	
	if [ $copy_err -z ] 2>/dev/null; then
		echo "> Copylogdb.err None"	
	else
		echo "$copy_err"	
	fi
	echo "--------------------------------------------------------------------"	
	echo "@ Applylogdb.err"	

	 if [ $apply_err -z ] 2>/dev/null; then
	 	echo "> Applylogdb.err None"	
	else
		echo "$apply_err"	
	fi
		echo "--------------------------------------------------------------------"	
		echo "@ backupdb.err"	
	if [ $backup_err -z ] 2>/dev/null; then
		echo "> Backupdb.err None"	
	else
		echo "$backup_err"	
	fi
	echo "--------------------------------------------------------------------"	

	for((i=0;i<${#lists_db[@]};i++));do
		echo "@ Server.err / DB Name : ${lists_db[i]}"
		find $CUBRID/log/server/${lists_db[i]}* -mtime -$old_new_diff -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' 
		echo "--------------------------------------------------------------------"
	done	
}

############### STEP_13. CUBRID DBMS User Core File Checking
function step_13(){
	echo "[STEP_13. CUBRID DBMS User Core File Checking]" 
	echo "********************************************************************"
	user_count=`find ~/ -name 'core*' |wc -l`
	engine_count=`find $CUBRID -name 'core*' |wc -l`
	i=0
	user_core=`find ~/ -name 'core*' -ls`
	engine_core=`find $CUBRID -name 'core*' -ls`

	if [ $user_count -gt $i ] 2>/dev/null; then
		echo "@ User Path"
		echo "$user_core"
		echo 
	else
		echo "@ User Path Core File None"
		echo
	fi

	if [ $engine_count -gt $i ] 2>/dev/null; then
		echo "@ Engine Path"
		echo "$engine_core"
	else
		echo "@ Engine Path Core File None"
	fi
	echo
}

############### STEP_14. CUBRID Owner user root File Checking
function step_14(){
	echo "[STEP_14. CUBRID Owner user root File Checking]" 
	echo "********************************************************************"	
	user_count=`find ~/ -user root |wc -l `
	engine_count=`find $CUBRID -user root |wc -l`
	i=0
	user_user=`find ~/ -user root -ls`
	engine_user=`find $CUBRID -user root -ls`

	if [ $user_count -gt $i ] 2>/dev/null; then
		echo "@ User Path"
		echo "$user_user"
		echo 

	else
		echo "@ User Path root Owner File None"
		echo
	fi

	if [ $engine_count -gt $i ] 2>/dev/null; then
		echo "@ Engine Path"
		echo "$engine_user"
	else
		echo "@ Engine Path root Owner File None"
	fi
	echo
}

############### STEP_15. dmesg (CUBRID Owner User) Checking
function step_15(){
	echo "[STEP_15. dmesg (CUBRID Owner User) Checking]" 
	echo "********************************************************************"
	dmesg_count=`dmesg |grep cub_ |wc -l`
	i=0
		if [ $dmesg_count -gt $i ]; then
			echo "@ dmesg Checking"
			dmesg |grep cub_
		else
			echo "@ dmesg None"
		fi
	echo
	
}

############### STEP_16. Manager Auto Job Checking
function step_16(){
	echo "[STEP_16. Manager Auto Job Checking]" 
	echo "********************************************************************"	
	echo "--------------------------------------------------------------------"	
		ls -lrth $CUBRID/conf |grep auto	
	echo "--------------------------------------------------------------------"	
}

############### STEP_17. Server.err Fatal or Internal Checking
function step_17(){
	echo "[STEP_17. Server.err Fatal or Internal Checking]" 
	echo "********************************************************************"	

	lists_db=(`cat $CUBRID/databases/databases.txt|grep -v "#db-name" |awk '{print $1}' |sort`)
	old_new_diff=30

	echo "--------------------------------------------------------------------"	

	for((i=0;i<${#lists_db[@]};i++));do
		echo "@ DB Name : ${lists_db[i]}"
		recent_err=(`find $CUBRID/log/server/${lists_db[i]}* -mtime -$old_new_diff 2>/dev/null`)

		for((x=0;x<${#recent_err[@]};x++));do

			recent_result=`cat ${recent_err[x]} | grep -E "fatal|internal" 2>/dev/null`

			if [ $recent_result -z ] 2>/dev/null ; then
				2>/dev/null
			else
				echo "> File Name : ${recent_err[x]}"	
				cat ${recent_err[x]} | grep -A3 -E "fatal|internal" 2>/dev/null
			fi

		done
		echo "--------------------------------------------------------------------"
	done	
}

############### STEP_18. Hosts File Checking
function step_18(){
	echo "[STEP_18. Hosts File Checking]" 
	echo "********************************************************************"
	echo "@ Hosts Date File Checking"
	ls -rlth /etc/hosts
	echo "--------------------------------------------------------------------"
	echo "@ Hosts File Contents Checking"
	cat /etc/hosts

}

############### STEP_19. ulimit Checking
function step_19(){
	echo "[STEP_19. ulimit Checking]" 
	echo "********************************************************************"
	i=0
	ulimit_count=`ulimit -a |wc -l`
	limit_count=`cat /etc/security/limits.conf |grep cub|wc -l`

	if [ $ulimit_count -gt $i ]; then
		echo "@ ulimit Checking"
		ulimit -a
		echo "--------------------------------------------------------------------"
	else
		echo "@ ulimit None"
	fi

	if [ $limit_count -gt $i ]; then
		echo "limits.conf Checking"
		cat /etc/security/limits.conf |grep cub
	else
		echo "@ limits.conf None"
	fi
}

###################################### Function List End.


###################################### sub Function List Start
function sub_01(){
	echo "********************************************************************"
	echo
	echo
}
###################################### sub Function End.


###################################### Function Start.
DATE_DIR=`date +%y%m%d_%H%M%S`

function fn_shell_version(){
	if [ $RD_INPUT -z] 2>/dev/null; then
		continue
	elif [ $RD_INPUT = "-v" ] 2>/dev/null; then
		echo
		echo "CUBRID Inspect Script 2018.03.15 (64bit release build for linux_gnu) (Mar 15 2018)"	
		echo
		exit		
	elif [ $RD_INPUT = "start" ] 2>/dev/null; then
		step_01 >> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_02	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_03	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_04	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_05	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
	
		step_06	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
	
		step_07	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_08	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_09	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_10	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_11	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_12	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_13	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_14	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
	
		step_15	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
	
		step_16	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_17	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_18	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log

		step_19	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		sub_01	>> $CUBRID/monitor/log/inspect/inspect_"$DATE_DIR".log
		
	elif [ $RD_INPUT != "-v" -o $RD_INPUT = "--help" ] 2>/dev/null ||  [ $RD_INPUT -z ] 2>/dev/null; then
		echo "CUBRID Inspect Script"
		echo "usage: sh cub_inspect.sh [option]"
		echo "        ./cub_inspect.sh [option]"
		echo
		echo "valid options:"
		echo "	start : Script Start"	
		echo "	-v : Version"			
		echo
		echo "This is a Script for CUBRID DBMS."
		exit	
	fi
}


	RD_INPUT=$1
	fn_shell_version 2>/dev/null

###################################### Function End.
