#!/bin/bash

#######################################################################
#              CUBRID Issue Script 
#               - Create by CUBRID Co.,Ltd.
#
#######################################################################

############################ CUBRID environment variables
function fn_env(){
ENV_NODAT=`ls ~/cubrid.sh 2>/dev/null `
ENV_DAT=`ls ~/.cubrid.sh  2>/dev/null`

if [ $ENV_DAT -z ] 2>/dev/null; then
	if [ $ENV_NODAT -z ] 2>/dev/null; then
		echo "Need to check CUBRID environment variables. "
	else
		. ~/cubrid.sh
	fi
else
	. ~/.cubrid.sh
fi
}


########################### create directory
DB_NAME=`cubrid server status |grep -v "@ cubrid server status" | awk '{print $2}'| sort 2>/dev/null`
DATE_DIR=`date +%y%m%d_%H%M%S`

########################### service check
function fn_service(){
echo "########## CUBRID SERVICE STATUS ###########"
cubrid service status
}

########################### CUBRID process check
function fn_process(){
	echo "########## CUBRID PROCESS STATUS ##########"
	ps -ef | grep cub_
}

########################### CUBRID process check
function fn_broker(){
	echo "########## CUBRID BROKER STATUS ###########" 
	cubrid broker status -f
}

########################### CUBRID lockdb check
function fn_lockdb(){
	echo "########## CUBRID LOCKDB STATUS ###########"
	for DB_NAME_RES in $DB_NAME 
		do
			echo "########## $DB_NAME_RES ###########"
			cubrid lockdb $DB_NAME_RES@localhost
			printf "\n\n\n"
		done
}

########################### CUBRID spacedb check
function fn_spacedb(){
	echo "########## file system CHECK ##########"
	df -h
	
	echo "########## DB VOLUME CHECK ##########" 
	for DB_NAME_RES1 in $DB_NAME 
		do
			echo "########### $DB_NAME_RES1 ###########"
			cubrid spacedb -s $DB_NAME_RES1@localhost
			printf "\n\n\n"
		done
}

############### CUBRID DBMS User Core File Checking
function fn_coredump(){
	echo "########## CUBRID DBMS User Core File Check ##########"    
	USER_COUNT=`find ~/ -name 'core*' |wc -l`
	ENGINE_COUNT=`find $CUBRID -name 'core*' |wc -l`
	IMSI_NUM=0
	USER_CORE=`find ~/ -name 'core*' -ls`
	ENGINE_CORE=`find $CUBRID -name 'core*' -ls`

	if [ $USER_COUNT -gt $IMSI_NUM ]; then	
		echo "@ User Path"  
		echo
		echo "$USER_CORE"  
		echo "--------------------------------------------------------------------"  
		echo  

	else
		echo "@ User Path Core File None"  
		echo "--------------------------------------------------------------------"  
	fi
	echo
	echo
	if [ $ENGINE_COUNT -gt $IMSI_NUM ]; then
		echo "@ Engine Path"  
		echo
		echo "$ENGINE_CORE"  
		echo "--------------------------------------------------------------------"  
	else
		echo "@ Engine Path Core File None"  
		echo "--------------------------------------------------------------------"  
	fi
	echo
	echo
  echo "########### dmesg status ###########"
	dmesg |grep -E "cub_server|cub_master"
	echo
	echo 
}

############### System Resource Check
function fn_top(){
	echo "########### System Resource Check ###########"
	top -u `whoami` -n 1
}

############### Shared Mermory Status Check
function fn_ipcs(){
	echo "########### Shared Mermory Status Check ###########"
	ipcs
}

############### broker_log tar
function fn_broker_log(){
	BROKER_SQL_DEFAULT_DIR="log/broker/sql_log"
	BROKER_CONF_DIR=`cat $CUBRID/conf/cubrid_broker.conf | grep "LOG_DIR" |grep -v '#'| grep -v 'error' | awk '{print $2}' | sed 's/=//g'|uniq`
	
	
	for BROKER_DIR_NEW in $BROKER_CONF_DIR
		do
		
			if [ $BROKER_DIR_NEW = $BROKER_SQL_DEFAULT_DIR ]; then 
				cd $CUBRID/$BROKER_SQL_DEFAULT_DIR
				cd ..
				nohup 1>>/dev/null 2>/dev/null tar -czvf $CUBRID/monitor/log/issue/$DATE_DIR/broker_log.tar.gz sql_log &
				
				
			else 			
				cd $BROKER_DIR_NEW
				cd ..
				nohup 1>>/dev/null 2>/dev/null tar -czvf $CUBRID/monitor/log/issue/$DATE_DIR/broker_log.tar.gz sql_log &
				
			fi
		done
	
}

############### CUBRID Owner user root File Check
function fn_owner(){
	echo "########## CUBRID Owner user root File Check ##########" 
	ENGINE_COUNT=`find $CUBRID -user root |wc -l`
	ENGINE_USER=`find $CUBRID -user root -ls`
	IMSI_NUM=0

	if [ $ENGINE_COUNT -gt $IMSI_NUM ]; then
		echo "@ Engine Path" 
		echo "$ENGINE_USER" 
		else
		echo "@ Engine Path root Owner File None" 
	fi
	echo 
}

############### function start


########################### CUBRID script version check
function fn_shell_version(){
   if [ $RD_INPUT -z] 2>/dev/null; then
      continue
   elif [ $RD_INPUT = "-v" ] 2>/dev/null; then
      echo
      echo "CUBRID Issue Script 2018.03.15 (64bit release build for linux_gnu) (Mar 15 2018)"   
      echo
      exit
   elif [ $RD_INPUT = "start" ] 2>/dev/null; then
   		fn_env
   		mkdir -p $CUBRID/monitor/log/issue/$DATE_DIR 2>/dev/null
			fn_broker_log
			fn_service >> $CUBRID/monitor/log/issue/$DATE_DIR/cub_service.log
			fn_process >> $CUBRID/monitor/log/issue/$DATE_DIR/cub_process.log
			fn_broker >> $CUBRID/monitor/log/issue/$DATE_DIR/cub_broker.log
			fn_lockdb >> $CUBRID/monitor/log/issue/$DATE_DIR/cub_lockdb.log
			fn_spacedb >> $CUBRID/monitor/log/issue/$DATE_DIR/cub_spacedb.log
			fn_coredump >> $CUBRID/monitor/log/issue/$DATE_DIR/cub_coredump.log
			fn_top >> $CUBRID/monitor/log/issue/$DATE_DIR/cub_top.log
			fn_ipcs >> $CUBRID/monitor/log/issue/$DATE_DIR/cub_shared_memory.log
			fn_owner >> $CUBRID/monitor/log/issue/$DATE_DIR/cub_owner.log
	
	elif [ $RD_INPUT != "-v" -o $RD_INPUT = "--help" ] 2>/dev/null ||  [ $RD_INPUT -z ] 2>/dev/null; then
		echo "CUBRID issue Script"
		echo "usage: sh cub_issue.sh [option]"
		echo "        ./cub_issue.sh [option]"
		echo
		echo "valid options:"
		echo "	start : Script Start"	
		echo "	   -v : Version"			
		echo
		echo "This is a Script for CUBRID DBMS."
		exit	
	fi
}


# Version Check argument
# -v
RD_INPUT=$1
fn_shell_version 2>/dev/null


