#!/bin/bash

#######################################################################
#              CUBRID Monitor Script 
#               - Create by CUBRID Co.,Ltd.
#
#######################################################################


# Variable -------------------------------
function fn_origin_variable(){
DB_NAME_RES=value
BROKER_NAME_RES=value

DB_LIST_RES=`cubrid server status | grep -vE "@|cubrid" | awk '{print $2}'`
HA_LIST_RES=`cubrid server status 2>/dev/null |grep HA | grep -vE "@|cubrid" | grep -v + |awk '{print $2}'`
BROKER_LIST_RES=`cubrid broker status -b | awk '{print $2}' | sed '1,3d' | sed '$d'`

IMSI_CNT=1
IMSI_RETURN=0
}

# Sub function -------------------------------
function fn_shell_version(){
   if [ $RD_INPUT -z] 2>/dev/null; then
      continue
   elif [ $RD_INPUT = "-v" ] 2>/dev/null; then
      echo
      echo "CUBRID Monitor Script 2018.03.15 (64bit release build for linux_gnu) (Mar 15 2018)"   
      echo
      exit      
   elif [ $RD_INPUT = "start" ] 2>/dev/null; then
      START_SIGN="y"
   elif [ $RD_INPUT != "-v" -o $RD_INPUT = "--help" ] 2>/dev/null ||  [ $RD_INPUT -z ] 2>/dev/null; then
      echo "CUBRID Monitor Script"
      echo "usage: sh cub_monitor.sh [option]"
      echo "        ./cub_monitor.sh [option]"
      echo
      echo "valid options:"
      echo "   start : Script Start"   
      echo "      -v : Version"         
      echo
      echo "This is a Script for CUBRID DBMS."
      exit   
   fi
}

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

function fn_dblist(){ 
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
if [ -z $DB_LIST_RES ]
then
	echo
	echo " All DB is not running                       "
	echo
else
echo " 0. ALL                              "
DB_LIST[0]="ALL"
for DB_NAME in $DB_LIST_RES
do
	echo " $IMSI_CNT. $DB_NAME                      "
	DB_LIST[$IMSI_CNT]=`echo $DB_NAME`
	IMSI_CNT=`expr $IMSI_CNT + 1`
done
fi
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
IMSI_RETURN=0
until [ "$IMSI_RETURN" == 1 ]
do
	echo -e " Input DB Name : \c                    "
	read DB_CHOICE
	if [ "$DB_CHOICE" == 'q' ]
	then
		break
	else
		for DB_NAME in $DB_LIST_RES
		do
			if [ "$DB_CHOICE" == $DB_NAME ]
			then
				IMSI_RETURN=1
			elif [ "$DB_CHOICE" == 'ALL' ]
			then
				IMSI_RETURN=1
			elif [[ $DB_CHOICE =~ ^[0-9]+$ ]] && [ "$DB_CHOICE" -lt "$IMSI_CNT" ]
			then 
				IMSI_RETURN=1
			fi
		done
		if [ "$IMSI_RETURN" == 0 ]
		then
			echo "   You entered an invalid db-name"
		fi
	fi
done
if [ "$DB_CHOICE" == 'q' ]
then
	break
else
	if [ "$DB_CHOICE" == 'ALL' ] || [ "$DB_CHOICE" == '0' ]
	then
		DB_NAME_RES="$DB_LIST_RES"
	elif [[ $DB_CHOICE =~ ^[0-9]+$ ]]
	then
		DB_NAME_RES="${DB_LIST[$DB_CHOICE]}"
	else
		DB_NAME_RES=$DB_CHOICE
	fi
fi
}

function fn_halist(){ 
IMSI_CNT=1
echo "-------------------------------------"
echo " HA-Server List                      "
echo "-------------------------------------"
if [ -z $HA_LIST_RES ]
then
        echo
        echo " HA-server is not running                       "
        echo
else
echo " 0. ALL                              "
HA_LIST[0]="ALL"
for DB_NAME in $HA_LIST_RES
do
	echo " $IMSI_CNT. $DB_NAME                 "
	HA_LIST[$IMSI_CNT]=`echo $DB_NAME`
	IMSI_CNT=`expr $IMSI_CNT + 1`
done
fi
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
IMSI_RETURN=0
until [ "$IMSI_RETURN" == 1 ]
do
	echo -e " Input HA-server Name : \c               "
	read DB_CHOICE
	if [ "$DB_CHOICE" == 'q' ]
	then
		break
	else
		for DB_NAME in $HA_LIST_RES
		do
			if [ "$DB_CHOICE" == $DB_NAME ]
			then
				IMSI_RETURN=1
			elif [ "$DB_CHOICE" == 'ALL' ]
			then
				IMSI_RETURN=1
			elif [[ $DB_CHOICE =~ ^[0-9]+$ ]] && [ "$DB_CHOICE" -lt "$IMSI_CNT" ]
			then
				IMSI_RETURN=1
			fi
		done
		if [ $IMSI_RETURN == 0 ]
		then
			echo "   You entered an invalid db-name"
		fi
	fi
done
if [ "$DB_CHOICE" == 'q' ]
then
	echo $DB_CHOICE
	break
else
	if [ "$DB_CHOICE" == 'ALL' ] || [ "$DB_CHOICE" == '0' ]
	then
		DB_NAME_RES="$HA_LIST_RES"
	elif [[ "$DB_CHOICE" =~ ^[0-9]+$ ]]
	then
		DB_NAME_RES="${HA_LIST[$DB_CHOICE]}"
	else
		DB_NAME_RES=$DB_CHOICE
	fi
fi
}

function fn_brokerlist(){ 
echo "-------------------------------------"
echo " Broker List                             "
echo "-------------------------------------"
if [ -z "$BROKER_LIST_RES" ]
then
        echo
        echo " All DB is not running                       "
        echo
else

echo " 0. ALL                              "
BROKER_LIST[0]="ALL"
for BROKER_NAME in $BROKER_LIST_RES
do
	echo " $IMSI_CNT. $BROKER_NAME                      "
	BROKER_LIST[$IMSI_CNT]=`echo $BROKER_NAME`
	IMSI_CNT=`expr "$IMSI_CNT" + 1`
done
fi
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
until [ "$IMSI_RETURN" == 1 ]
do
	echo -e " Input Broker Name : \c                    "
	read BROKER_CHOICE
	if [ "$BROKER_CHOICE" == 'q' ]
	then
		break
	else
		for BROKER_NAME in $BROKER_LIST_RES
		do
			if [ "$BROKER_CHOICE" == "$BROKER_NAME" ]
			then
				IMSI_RETURN=1
			elif [ "$BROKER_CHOICE" == 'ALL' ] || [ "$BROKER_CHOICE" == '0' ]
			then
				IMSI_RETURN=1
			elif [[ $BROKER_CHOICE =~ ^[0-9]+$ ]] && [ "$BROKER_CHOICE" -lt "$IMSI_CNT" ]
			then 
				IMSI_RETURN=1
			fi
		done
		if [ "$BROKER_LIST_RES" -z ]
		then
		        IMSI_RETURN=1
		fi

			if [ $IMSI_RETURN == 0 ]
			then
				echo "   You entered an invalid broker-name"
			fi
	fi
done
clear
if [ "$BROKER_CHOICE" == 'q' ]
then
	break
else
	if [ "$BROKER_CHOICE" == 'ALL' ] || [ "$BROKER_CHOICE" == '0' ]
	then
		BROKER_NAME_RES="$BROKER_LIST_RES"
	elif [[ $BROKER_CHOICE =~ ^[0-9]+$ ]]
	then
		BROKER_NAME_RES="${BROKER_LIST[$BROKER_CHOICE]}"
	else
		BROKER_NAME_RES=$BROKER_CHOICE
	fi
fi
}

function  fn_userinput() {
USER_ID=""
echo -e " Input User Name : \c "
read USER_ID
stty echo
if [ "$USER_ID" != "" ]
then
        USER_ID="$USER_ID"
else
        echo "   You entered an invalied user-name "
        user_id
fi
}

function fn_passinput(){
IMSI_RETURN=0
until [ $IMSI_RETURN == 1 ]
do
 	echo -e " Input your $DB_NAME DBA Password : \c"
	stty -echo
 	read DBA_PASS
 	stty echo
	echo
	 if [ -z $DBA_PASS ]
        then
                IMSI_PASS_CONFIRM=`csql -u dba -p '' $DB_NAME@localhost -c 'select 1 from db_root' 2>/dev/null`
        else
                IMSI_PASS_CONFIRM=`csql -u dba -p "$DBA_PASS" $DB_NAME@localhost -c 'select 1 from db_root' 2>/dev/null`
		DBA_PASS="-p $DBA_PASS"
        fi
        if [ -z "$IMSI_PASS_CONFIRM" ]
        then
		echo "   You entered an invalid dba-password"
        else
		IMSI_RETURN=1
        fi
done
}

# Sub function -------------------------------

# 1.GENERAL ------------------------------
function fn_service_info(){
Master=`cubrid service status | grep "master is" | sed -n '1p' | awk '{print $5}'| sed -e 's/[.]//g'`
if [ $Master = 'not' ]
	then
		Mast_status="Not Running"
	else
		Mast_status="Running"
	fi

echo " 1. Master                          "
echo "      Master status : $Mast_status  "
echo
echo "------------------------------------"
echo
echo " 2. DB                              "
IMSI_CNT=1
DB_list=`cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d'`
ha_list=`cat $CUBRID/conf/cubrid_ha.conf | grep -v '#' | grep -w ha_db_list | cut -d '=' -f2 | sed -e 's/,/ /g'`
DB_mode="Single"
for DB_NAME in `cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d'`
do
echo "    2-$IMSI_CNT. $DB_NAME                    "
        DB_stat=`cubrid server status 2>/dev/null |grep -v @ | grep -v +| grep -w "$DB_NAME" | awk '{print $1}'`
        if [ -z $DB_stat ]
        then
                DB_status="Not Running"
        else
                DB_status="Running"
        for HA_NAME in `cat $CUBRID/conf/cubrid_ha.conf | grep -v '#' | grep -w ha_db_list | cut -d '=' -f2 | sed -e 's/,/ /g'`
        do
                if [ "$HA_NAME" == "$DB_NAME" ]
                then
                        DB_mode="HA"
                        break
                else
                        DB_mode="Single"
                fi
        done
fi
echo "      DB mode       : $DB_mode              "
echo "      DB Status     : $DB_status            "
echo
IMSI_CNT=`expr $IMSI_CNT + 1`
done
echo "------------------------------------"
echo
echo " 3. Broker                          "
IMSI_CNT=1
Bro_list=`cat $CUBRID/conf/cubrid_broker.conf | grep % | sed -e 's/[[]//g' | sed -e 's/[]]//g' | sed -e 's/%//g'`
for Bro_Name in `cat $CUBRID/conf/cubrid_broker.conf | grep % | sed -e 's/[[]//g' | sed -e 's/[]]//g' | sed -e 's/%//g'`
do
echo "    3-$IMSI_CNT. $Bro_Name                    "
        Bro_stat=`cubrid broker status -b  | grep -i "$Bro_Name" | awk '{print $2}'`
        if [ -z $Bro_stat ]
        then
                Bro_status="Not Running"
        else
                Bro_status="Running"
        fi
echo "      Broker Status : $Bro_status            "
echo
IMSI_CNT=`expr $IMSI_CNT + 1`
done

echo "------------------------------------"
echo
echo " 4. Manager                         "
Manager=`cubrid manager status | grep running | awk '{print $6}'`
if [ $Manager = 'not' ]
        then
                Mng_status="Not Running"
        else
                Mng_status="Running"
        fi
echo "     Manager Status : $Mng_status           "
echo
echo "*************************************"
}

function fn_system_info(){
HOST_NAME_CURR=`hostname`
OS_VERSION=`cat /etc/redhat-release`
KERNEL_VERSION=`uname -a | awk '{print $3}'`
CPU=`grep -c processor /proc/cpuinfo`
SOCKET=`lscpu | grep -w "Socket(s):" | awk '{print $2}'`
MEMORY=`cat /proc/meminfo | grep MemTotal | awk '{print $2, $3}'`
echo "-------------------------------------"
echo " System Info                         "
echo "-------------------------------------"
echo " 1. Hostname       : $HOST_NAME_CURR "
echo " 2. Linux Version  : $OS_VERSION     "
echo " 3. Kernal_version : $KERNEL_VERSION "
echo " 4. CPU core       : $CPU            "
echo " 5. CPU Socket     : $SOCKET         "
echo " 6. Memory Total   : $MEMORY         "
echo "-------------------------------------"
}

function fn_version_info(){
cubrid_rel
}

function fn_backup_status(){
fn_origin_variable
fn_dblist
for DB_NAME in $DB_NAME_RES
do
	clear
	echo "-------------------------------------"
	echo " $DB_NAME Backup Status            "
	echo "-------------------------------------"
	echo
	BACK_DEST_01=`cat $CUBRID/databases/databases.txt | grep $DB_NAME | awk '{print $4}'`
	if [ -e "$BACK_DEST_01"/"$DB_NAME"_bkvinf ]
	then
		BACK_TIME=`ls -al $BACK_DEST_01 | grep "$DB_NAME"_bkvinf | awk '{print $6, $7, $8}'`
		BACK_DEST_RES=`cat "$BACK_DEST_01"/"$DB_NAME"_bkvinf | awk '{print $3}'`
			if [ -e "$BACK_DEST_RES" ]
			then
				echo " Backup Location  : $BACK_DEST_RES "	
				echo " Last Backup Time : $BACK_TIME "
				echo
				echo " Backup file status : "
				ls -al $BACK_DEST_RES
			else 
				echo " $DB_NAME backup file does not exist. "
			fi
		echo
		echo
	else
		echo " $DB_NAME backup file does not exist. "
	fi
	if [ "$DB_NAME" != `echo $DB_NAME_RES | awk '{print $NF}'` ]
	then
        echo
        echo "----------------------------------"
        echo " Press Enter to continue. "
		echo "----------------------------------"
        read
        clear
	fi
done
}

function fn_volume_location(){
IMSI_CNT=1
DB_LIST=`cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d'`
for DB_NAME in $DB_LIST
do
echo "-------------------------------------"
echo " $IMSI_CNT. $DB_NAME                      "
echo "-------------------------------------"
        DATA_VOL_LOC=`cat $CUBRID/databases/databases.txt | sed '/#/d' | grep $DB_NAME | awk '{print $2}'`
        LOG_VOL_LOC=`cat $CUBRID/databases/databases.txt | sed '/#/d' | grep $DB_NAME | awk '{print $4}'`
        LOB_FILE_LOC=`cat $CUBRID/databases/databases.txt | sed '/#/d' | grep $DB_NAME | awk '{print $5}'`
echo
echo " DataVolume_Location  :  $DATA_VOL_LOC       "
echo " LogVolume_Location   :  $LOG_VOL_LOC       "
echo " Lobfile_Location     :  $LOB_FILE_LOC       "
echo
IMSI_CNT=`expr $IMSI_CNT + 1`
done
}

# 2.DataBase ------------------------------
function fn_database_status(){
IMSI_CNT=1
DB_list=`cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d'`
ha_list=`cat $CUBRID/conf/cubrid_ha.conf | grep -v '#'|  grep -w ha_db_list | cut -d '=' -f2 | sed -e 's/,/ /g'`
DB_mode="Single"
for DB_NAME in $DB_list
do
echo "-------------------------------------"
echo " $IMSI_CNT. $DB_NAME                      "
echo "-------------------------------------"
        DB_stat=`cubrid server status 2>/dev/null |grep -v @ | grep -v + | grep -w "$DB_NAME" | awk '{print $1}'`
        if [ -z $DB_stat ]
        then
                DB_status="Not Running"
        else
                DB_status="Running"
        for HA_NAME in $ha_list
        do
                if [ "$HA_NAME" == "$DB_NAME" ]
                then
                        DB_mode="HA"
                        break
                else
                        DB_mode="Single"
                fi
        done
        echo "      DB mode       : $DB_mode              "

        fi

echo "      DB Status     : $DB_status            "
echo
IMSI_CNT=`expr $IMSI_CNT + 1`
done
}

function fn_database_space(){
fn_origin_variable
fn_dblist
for DB_NAME in $DB_NAME_RES
do
	clear
	echo "-------------------------------------"
	echo " $DB_NAME Space Info                 "
	echo "-------------------------------------"
   	cubrid spacedb -s $DB_NAME@localhost
    echo
	if [ $DB_NAME != `echo $DB_NAME_RES | awk '{print $NF}'` ]
	then
		echo "-------------------------------------"
		echo " Press Enter to Continue. "
		echo "-------------------------------------"
		read
		clear
	fi
done
}

function fn_database_config(){
cat $CUBRID/conf/cubrid.conf | grep -v '#' | sed '/^$/d' | sed 's/\[/\n\[/g'
}

function fn_user_info(){
fn_origin_variable
fn_dblist
for DB_NAME in $DB_NAME_RES
do
	fn_passinput
	clear
        echo "==================================="
        echo "       $DB_NAME User List          "
        echo "==================================="
        echo "    User name        Group name    "
        echo "-----------------------------------"
        echo "  DBA              "
        printf "  Public           "
        DB_USER_IMSI=`csql -u dba $DBA_PASS -c 'select u.name, x.name from db_user as u, TABLE(u.groups) as g(x);' $DB_NAME@localhost | sed '1,5d' | sed '$d'`
        DB_USER_LIST=(`echo $DB_USER_IMSI`)
        IMSI_CNT=1
        for DB_USER_NAME in ${DB_USER_LIST[@]}
        do
                DB_USER_NAME=${DB_USER_NAME/\'/}
                DB_USER_NAME=${DB_USER_NAME/\'/}
                if [ `expr $IMSI_CNT % 2` == 0 ]
                then
                        printf " $DB_USER_NAME"
                else
                        if [ $DB_USER_NAME != "$DB_USER_LAST" ]
                        then
                                echo
                                printf "  %-18s" $DB_USER_NAME
                                DB_USER_LAST=$DB_USER_NAME
                        fi
                fi
                IMSI_CNT=`expr $IMSI_CNT + 1`
        done
        echo
        echo "==================================="
        if [ $DB_NAME != `echo $DB_NAME_RES | awk '{print $NF}'` ]
        then
                  echo
                  echo "-------------------------------------"
                  echo " Press Enter to Continue. "
                  echo "-------------------------------------"
                  read
                  clear
        fi
done
}

function fn_database_statdump(){
fn_origin_variable
fn_dblist
for DB_NAME in $DB_NAME_RES
do
        clear
        echo "-------------------------------------"
        echo " $DB_NAME statdump Info              "
        echo "-------------------------------------"
        cubrid statdump  $DB_NAME@localhost | more
    echo
        if [ $DB_NAME != `echo $DB_NAME_RES | awk '{print $NF}'` ]
        then
                echo "-------------------------------------"
                echo " Press Enter to Continue. "
                echo "-------------------------------------"
                read
                clear
        fi
done
}

# 3.Broker ------------------------------
function fn_broker_status(){
if [ "not" == `cubrid broker status | grep "is" | awk '{print $5}'` ]
then
	echo " Broker is not running "
	echo
        echo "-------------------------------------"
        echo " Press Enter to Continue. "
        echo "-------------------------------------"
	read
else
	cubrid broker status -f -b -s 1
fi
}

function fn_broker_status_detail(){
cubrid broker status -f | more -30
}

function fn_broker_config(){
fn_origin_variable
fn_brokerlist
if [ -z  `echo $BROKER_NAME_RES | awk '{print $1}'` ]
then
        echo "-------------------------------------"
        echo " Broker config Info                  "
        echo "-------------------------------------"
        cat $CUBRID/conf/cubrid_broker.conf | grep -v '#' |sed '1,2d' | more
fi
if [ -z `echo $BROKER_NAME_RES | awk '{print $2}'` ]
then
	for BRO_NAME in $BROKER_NAME_RES
        do
		echo "-------------------------------------"
		echo " $BRO_NAME config Info             "
		echo "-------------------------------------"
		BRO_NAME=`cat $CUBRID/conf/cubrid_broker.conf | grep -i $BRO_NAME | sed 's/\[//g'`
		cat $CUBRID/conf/cubrid_broker.conf | sed -n '/'"$BRO_NAME"'/,/%/p' | sed '$d'
	done
else
        echo "-------------------------------------"
        echo " Broker config Info                  "
        echo "-------------------------------------"
	cat $CUBRID/conf/cubrid_broker.conf | grep -v '#' |sed '1,2d' | more
fi
}

function fn_broker_log_top(){
fn_origin_variable
fn_brokerlist
CUB_REL=`cubrid_rel |awk '{print $2}'|sed -n '2p'`
if [ "$CUB_REL" == "2008" ]; then
        CUB_REL=`cubrid_rel`
        CUB_REL_RESULT=`echo $CUB_REL |awk '{print $4}' |sed  's/(/ /g' | sed 's/)/ /g' | awk -F '[.]' '{print $1 $2 $3}'`
else
        CUB_REL=`cubrid_rel`
        CUB_REL_RESULT=`echo $CUB_REL |awk '{print $3}' |sed  's/(/ /g' | sed 's/)/ /g' | awk -F '[.]' '{print $1 $2 $3}'`
fi
if [ $CUB_REL_RESULT -ge 844 ]
then
        echo -e " Input the start time(yy-mm-dd hh:mm:ss) : \c              "
        read IMSI_FROM_TIME
        echo -e " Input the finish time(yy-mm-dd hh:mm:ss) : \c             "
        read IMSI_TO_TIME
else
        echo -e " Input the start time(mm/dd hh:mm:ss) : \c              "
        read IMSI_FROM_TIME
        echo -e " Input the finish time(mm/dd hh:mm:ss) : \c             "
        read IMSI_TO_TIME
fi
clear
for BRO_NAME in $BROKER_NAME_RES
do
BROKER_SQL_DEFAULT_DIR="log/broker/sql_log"
BROKER_SQL_LOG_DIR=`cat $CUBRID/conf/cubrid_broker.conf |grep -i -A15 $BRO_NAME |grep LOG_DIR |grep -v '#'|grep -v 'error'|awk '{print $2}'|sed -s 's/=//g'`
LOG_TOP_RES_DEST=$CUBRID/monitor/log/monitor
cd $LOG_TOP_RES_DEST
if [ $BROKER_SQL_LOG_DIR == $BROKER_SQL_DEFAULT_DIR ]
then
        if [ -z $IMSI_FROM_TIME ]
        then
                broker_log_top $CUBRID/log/broker/sql_log/$BRO_NAME* 1>/dev/null 2>/dev/null
        else
                broker_log_top -F "$IMSI_FROM_TIME" -T "$IMSI_TO_TIME" $CUBRID/log/broker/sql_log/$BRO_NAME* 1>/dev/null 2>/dev/null
        fi
else
        if [ -z $IMSI_FROM_TIME ]
        then
                broker_log_top $BROKER_SQL_LOG_DIR/$BRO_NAME* 1>/dev/null 2>/dev/null
        else
                broker_log_top -F "$IMSI_FROM_TIME" -T "$IMSI_TO_TIME" $BROKER_SQL_LOG_DIR/$BRO_NAME* 1>/dev/null 2>/dev/null
        fi
fi
mv $LOG_TOP_RES_DEST/log_top.q $LOG_TOP_RES_DEST/`date +"%Y%m%d_%H%M"`_"$BRO_NAME"_log_top.q
mv $LOG_TOP_RES_DEST/log_top.res $LOG_TOP_RES_DEST/`date +"%Y%m%d_%H%M"`_"$BRO_NAME"_log_top.res
done
echo
echo
echo "The location of the result(log_top.q, log_top.res) is $LOG_TOP_RES_DEST "
}


# 4.HA ------------------------------
function fn_ha_status(){
IMSI_CNT=1
HOST_NAME_CURR=`hostname`
HA_STATUS_CURR=`cubrid hb status 2>/dev/null | grep current | awk '{print $6}' | sed -e 's/)//g'`
if [ -z "$HA_STATUS_CURR" ]
then
	HA_STATUS_CURR="Not Running"
	echo "-------------------------------------"
	echo " 1. Current node HA Status           "
	echo "-------------------------------------"
	echo
        echo " The server was not configured for HA."
	echo
else
        echo "-------------------------------------"
        echo " 1. Current node HA Status           "
        echo "-------------------------------------"
	echo " Current node($HOST_NAME_CURR) : $HA_STATUS_CURR"
	
for HOST_NAME_OTH in `cubrid hb status | grep priority | awk '{print $2}' | sort`
do
        if [ $HOST_NAME_OTH != $HOST_NAME_CURR ]
        then
        HA_STATUS_OTH=`cubrid hb status | grep priority | grep $HOST_NAME_OTH | awk '{print $6}' | sed -e 's/)//g'`
        echo " Other   node($HOST_NAME_OTH) : $HA_STATUS_OTH    "
        fi
done
echo "-------------------------------------"
echo
echo
echo "-------------------------------------"
echo " 2. HA-Server List                   "
echo "-------------------------------------"
for DB_NAME in `cat $CUBRID/conf/cubrid_ha.conf | grep -v '#' | grep -w ha_db_list | cut -d '=' -f2 | sed -e 's/,/ /g'`
do
DB_STATUS_CURR=`cubrid changemode $DB_NAME@localhost 2>/dev/null| awk '{print $9}' | sed -e 's/[.]//g'`
HA_STATUS_APPLY=`cubrid hb status | grep $DB_NAME | grep Apply | awk '{print $1}'`
HA_STATUS_COPY=`cubrid hb status | grep $DB_NAME | grep Copy | awk '{print $1}'`
if [ -z "$DB_STATUS_CURR" ]
then
	DB_STATUS_CURR="Not Running"
fi
if [ -z "$HA_STATUS_APPLY" ]
then
	HA_STATUS_APPLY_RES="Not Running"
else
	HA_STATUS_APPLY_RES="Running"
fi
if [ -z "$HA_STATUS_COPY" ]
then
	HA_STATUS_COPY_RES="Not Running"
else
	HA_STATUS_COPY_RES="Running"
fi
echo "2-$IMSI_CNT. $DB_NAME                     "
echo
echo "      DB Status     : $DB_STATUS_CURR  "
echo "      Applylogdb    : $HA_STATUS_APPLY_RES"
echo "      Copylogdb     : $HA_STATUS_COPY_RES"
echo
IMSI_CNT=`expr $IMSI_CNT + 1`
done
fi
echo "-------------------------------------"
echo
echo
}

function fn_ha_apply_info(){
fn_origin_variable
fn_halist
HOST_NAME_CURR=`hostname`
HOST_NAME_OTH=`cubrid hb status | grep priority | grep -v $HOST_NAME_CURR | awk '{print $2}' | sort`
for DB_NAME in $DB_NAME_RES
do
	clear
	HA_COPY_DEST=`cubrid hb status | grep Applylogdb | grep $DB_NAME |sed "s/${DB_NAME}@localhost://g" | awk '{print $2}'`
	for HOST_NAME_RES in $HOST_NAME_OTH
	do
		HA_STATUS=`cubrid hb status | grep priority | grep -w "$HOST_NAME_RES" | awk '{print $6}'`
		if [ $HA_STATUS != 'replica)' ]
		then
			if [ $HA_STATUS != 'unknown)' ]
			then
				echo "-------------------------------------"
				echo " $DB_NAME HA Apply Info($HOST_NAME_RES)     "
				echo "-------------------------------------"
					cubrid applyinfo -a -r "$HOST_NAME_RES" -L $HA_COPY_DEST ${DB_NAME}
				echo
				if [ $DB_NAME != `echo $DB_NAME_RES | awk '{print $NF}'` ]
				then
				     echo "-------------------------------------"
				     echo " Press Enter to Continue. "
				     echo "-------------------------------------"
				     read
				     clear
				 fi
			fi
		fi
	done
done
}

function fn_ha_warning(){
fn_origin_variable
fn_halist
for DB_NAME in $DB_NAME_RES
do
	fn_passinput
	HOST_NAME_MASTER=`cubrid hb status | grep priority | grep master | awk '{print $2}'`
	HOST_NAME_SLAVE=`cubrid hb status | grep priority | grep slave | awk '{print $2}' | sort | sed -n '1p'`
	clear
	HA_WARNING_LIST=`csql -u dba $DBA_PASS -c "select 'NON_PK', class_name \
	from db_class \
	where class_type='CLASS' and is_system_class='NO' \
	and class_name not in (select distinct class_name from db_index where is_primary_key='YES') \
	union all select 'SP', sp_name from db_stored_procedure \
	union all select data_type, class_name||' '||attr_name as table_column from db_attribute \
	where data_type in ('CLOB','BLOB') \
	union all select 'Serial Cache', name from db_serial where cached_num >0 " $DB_NAME@$HOST_NAME_MASTER`
	HA_WARNING_NONPK_CNT=`echo "$HA_WARNING_LIST" | sed '1,5d' | grep "NON_PK" | wc -l`
	HA_WARNING_SP_CNT=`echo "$HA_WARNING_LIST" | sed '1,5d' |  grep "SP" |  wc -l`
	HA_WARNING_CLOB_CNT=`echo "$HA_WARNING_LIST" | sed '1,5d' |  grep "CLOB" |  wc -l`
	HA_WARNING_BLOB_CNT=`echo "$HA_WARNING_LIST" | sed '1,5d' |  grep "BLOB" |  wc -l`
	HA_WARNING_SERIAL_CNT=`echo "$HA_WARNING_LIST" | sed '1,5d' |  grep "Serial" | wc -l`
	echo "===================================="
	echo "        HA Warning Summary          "
	echo "===================================="
	echo "    case                  value     "
	echo "------------------------------------"
	echo "  'NON_PK'                  $HA_WARNING_NONPK_CNT"
	echo "  'SP'                      $HA_WARNING_SP_CNT"
	echo "  'CLOB'                    $HA_WARNING_CLOB_CNT"
	echo "  'BLBO'                    $HA_WARNING_BLOB_CNT"
	echo "  'Serial Cache'            $HA_WARNING_SERIAL_CNT"
	echo "===================================="
	echo
	echo
	echo "===================================="
	echo "           HA Warning List          " 
	echo "===================================="
	echo "    case                  value     "
	echo "------------------------------------"
	echo "$HA_WARNING_LIST" | sed '1,5d' | grep "'"
	echo "===================================="
	echo
	echo
	echo -e " Do you confirm the comparison of the non_pk tables?(Y/N) : \c "
	read IMSI_ANSWER
	if [[ `echo $IMSI_ANSWER | grep "^[Yy]$\|^[Yy][Ee][Ss]$" | wc -l` -ge 1 ]]
	then
		clear
		HA_WARNING_NONPK_LIST=`csql -u dba $DBA_PASS -c "select 'NON_PK' x, class_name \
		from db_class \
		where class_type='CLASS' and is_system_class='NO' \
		and class_name not in (select distinct class_name from db_index where is_primary_key='YES')" $DB_NAME@$HOST_NAME_MASTER | grep "NON_PK" | awk '{print $2}'`
		HA_WARNING_NONPK_TOTAL=`echo "$HA_WARNING_NONPK_LIST" | wc -l`
		echo "======================================================================================"
		echo "                                   NON PK Table Count                                 "
		echo "======================================================================================"
		echo " Table name                   Master           Slave            Diff         Progress "
		echo "--------------------------------------------------------------------------------------"
		HA_NONPK_COMPARE_CNT=1
		for HA_NONPK_TBL_NAME in $HA_WARNING_NONPK_LIST
		do
		        HA_COMPARE_PROGRESS=`expr $HA_NONPK_COMPARE_CNT \* 100 / $HA_WARNING_NONPK_TOTAL`
			HA_NONPK_TBL_NAME=${HA_NONPK_TBL_NAME/\'/}
			HA_NONPK_TBL_NAME=${HA_NONPK_TBL_NAME/\'/}
			HA_NONPK_MASTER_CNT=`csql -u dba $DBA_PASS -c "select count(*) from $HA_NONPK_TBL_NAME" $DB_NAME@$HOST_NAME_MASTER 2>&1 | sed -n 6p | awk '{print $1}'`
			HA_NONPK_SLAVE_CNT=`csql -u dba $DBA_PASS -c "select count(*) from $HA_NONPK_TBL_NAME" $DB_NAME@$HOST_NAME_SLAVE 2>&1 | sed -n 6p | awk '{print $1}'`
			if [ -z $HA_NONPK_SLAVE_CNT ]
			then
				HA_NONPK_SLAVE_CNT=0
			fi
			HA_TBL_COMPARE_DIFF=`expr $HA_NONPK_MASTER_CNT - $HA_NONPK_SLAVE_CNT 2>/dev/null`
			printf "%-20s %15d %15d %15d %15d" $HA_NONPK_TBL_NAME $HA_NONPK_MASTER_CNT $HA_NONPK_SLAVE_CNT $HA_TBL_COMPARE_DIFF $HA_COMPARE_PROGRESS
			echo "%"
			HA_NONPK_COMPARE_CNT=`expr $HA_NONPK_COMPARE_CNT + 1`
		done
		echo "======================================================================================"
	fi
	if [ $DB_NAME != `echo $DB_NAME_RES | awk '{print $NF}'` ]
	then
		echo
	        echo "-------------------------------------"
	        echo " Press Enter to Continue. "
	        echo "-------------------------------------"
	        read
	        clear
	fi
done
}


function fn_ha_config(){
cat $CUBRID/conf/cubrid_ha.conf  | grep -v '#' | sed '/^$/d' 
}

# 5.Transaction / Lock ------------------------------
fn_transaction_status(){
fn_origin_variable
fn_dblist
for DB_NAME in $DB_NAME_RES
do
	fn_passinput
	clear
	echo "-------------------------------------"
	echo " $DB_NAME Transaction Status       "
	echo "-------------------------------------"
	echo
	tran=`cubrid killtran $DBA_PASS $DB_NAME@localhost -q 2>/dev/null | awk '{print $1}'`
	if [ -z "$tran" ]
	then
		cubrid killtran $DBA_PASS $DB_NAME@localhost | sed -n '1,2p'
		cubrid killtran $DBA_PASS $DB_NAME@localhost | sed '1,2d' | sort -k4 -r
	else
                cubrid killtran -q $DBA_PASS $DB_NAME@localhost | sed -n '1,2p'
                cubrid killtran -q $DBA_PASS $DB_NAME@localhost | sed '1,2d' | sort -k4 -r
	fi
	echo
	echo -e " Will you kill the transaction?(Y/N) : \c "
	read IMSI_ANSWER
	if [[ `echo $IMSI_ANSWER | grep "^[Yy]$\|^[Yy][Ee][Ss]$" | wc -l` -ge 1 ]]
	then
        	echo -e " Input Transaction ID : \c            "
       		read Tran_ID
        	cubrid killtran $DBA_PASS -i $Tran_ID $DB_NAME@localhost
	fi
        if [ $DB_NAME != `echo $DB_NAME_RES | awk '{print $NF}'` ]
        then
		echo
		echo
                echo "-------------------------------------"
                echo " Press Enter to Continue. "
                echo "-------------------------------------"
                read
                clear
        fi

done
}

function fn_lock_status(){
fn_origin_variable
fn_dblist
for DB_NAME in $DB_NAME_RES
do
	clear
	echo "-------------------------------------"
	echo " $DB_NAME Lock Status              "
	echo "-------------------------------------"
	echo
	cubrid lockdb $DB_NAME@localhost | more -30
	echo
	if [ $DB_NAME != `echo $DB_NAME_RES | awk '{print $NF}'` ]
	then
	    echo "-------------------------------------"
	    echo " Press Enter to Continue. "
	    echo "-------------------------------------"
	    read
	    clear
	fi
done
}

# 6.Other ------------------------------
function fn_csql(){
fn_origin_variable
fn_dblist
for DB_NAME in $DB_NAME_RES
do
	fn_passinput
	clear
	echo "==============================="
	echo " $DB_NAME   "
	echo "==============================="
	csql -u dba $DBA_PASS $DB_NAME@localhost
done
}

function fn_table_size_info(){
fn_origin_variable
fn_dblist
TABLE_SIZE_TOTAL=0
for DB_NAME in $DB_NAME_RES
do
	fn_passinput
	echo -e " Do you want to check the capacity of all the tables?[Y/N] : \c " 
	read IMSI_ANSWER
	if [[ `echo $IMSI_ANSWER | grep "^[Yy]$\|^[Yy][Ee][Ss]$" | wc -l` -ge 1 ]] || [ -z "$IMSI_ANSWER" ]
	then
		TABLE_LIST_RES=`csql -u dba $DBA_PASS -c "select class_name from db_class where class_type = 'CLASS' and is_system_class ='NO';" -l $DB_NAME@localhost | grep "class_name" | awk '{print $3}' | sed '2d' | sed '/^$/d' | sed "s/'//g" `
	else
                echo -e " Input Table name : \c"
                read TABLE_LIST_RES
	fi
	clear
        echo "=========================================="
        echo "              TABLE SIZE INFO             "
        echo "=========================================="
	echo "    Table name              Size          "
	echo "------------------------------------------"
	for TABLE_NAME in $TABLE_LIST_RES
	do
		echo ";info stats $TABLE_NAME" >> $CUBRID/monitor/log/monitor/table_size_imsi.txt
		TABLE_PAGE_NUM=`csql -u dba $DBA_PASS -i $CUBRID/monitor/log/monitor/table_size_imsi.txt  $DB_NAME@localhost | grep "Total pages in class heap:" | awk '{print $6}'`
		if [ "$TABLE_PAGE_NUM" == 0 ] || [ -z "$TABLE_PAGE_NUM" ]
		then
			TABLE_PAGE_NUM=1
		fi
		TABLE_SIZE=`echo "$TABLE_PAGE_NUM * 16" | bc`
		TABLE_SIZE_TOTAL=`echo "$TABLE_SIZE_TOTAL + $TABLE_SIZE" | bc`
		printf "%-20s %15d" $TABLE_NAME $TABLE_SIZE
		echo "KB"
		rm $CUBRID/monitor/log/monitor/table_size_imsi.txt
	done
	if [[ `echo $IMSI_ANSWER | grep "^[Yy]$\|^[Yy][Ee][Ss]$" | wc -l` -ge 1 ]] || [ -z "$IMSI_ANSWER" ]
        then
		echo
		echo "------------------------------------------"
		printf "%-20s %15d" "All tables total"  $TABLE_SIZE_TOTAL
		echo "KB"
		echo "------------------------------------------"
	fi
        if [ $DB_NAME != `echo $DB_NAME_RES | awk '{print $NF}'` ]
        then
		echo
		echo
	        echo "------------------------------------------"
	        echo " Press Enter to Continue. "
	        echo "------------------------------------------"
        	read
        	clear
 	fi
done
}

RD_INPUT=$1
fn_shell_version
fn_env
if [ $START_SIGN =! "y" ]
then
	break;
fi

while true
do
clear
echo " ==================================================================== "
echo "  CUBRID Moniter Script                                               "
echo " ==================================================================== "
echo "  1.GENERAL                        |  2.DataBase                      "
echo " -------------------------------------------------------------------- "
echo "  11 - Service Status              |  21 - Database Status            "
echo "  12 - System Info                 |  22 - Database Space             "
echo "  13 - Version Info                |  23 - Database config            "
echo "  14 - Backup Status               |  24 - Database User Info         "
echo "  15 - Volume Location Info        |  25 - Database Statistics        "
echo " -------------------------------------------------------------------- "
echo "  3.Broker                         |  4.HA                            "
echo " -------------------------------------------------------------------- "
echo "  31 - Broker status               |  41 - HA Status                  " 
echo "  32 - Broker status(detail)       |  42 - HA apply info              "
echo "  33 - Broker config               |  43 - HA Warning                 "
echo "  34 - Broker log top              |  44 - HA config                  "
echo " -------------------------------------------------------------------- "
echo "  5.Transaction / Lock             |  6.OTHER                         "
echo " -------------------------------------------------------------------- "
echo "  51 - Transaction status          |  61 - CSQL                       "
echo "  52 - Lock status                 |  62 - Table Size Info            "
echo " -------------------------------------------------------------------- "
echo "  7.HELP                           |  0.EXIT                          "
echo " -------------------------------------------------------------------- "
echo "  71 - Restart Help                |  00 - Exit                       "
echo "  72 - Add Volume Help             |                                  "
echo "  73 - HA Warning Help             |                                  "
echo " ==================================================================== "
echo
echo -e "Input the Number : \c"
read number
case $number in

# 1.GENERAL ------------------------------------
11)
clear
echo "====================================="
echo " 11 - Service Status                 "
echo "====================================="
echo
fn_service_info
echo
echo " Press Enter to continue..."
read 
;;

12)
clear
echo "====================================="
echo " 12 - System Info                    "
echo "====================================="
echo
fn_system_info
echo
echo " Press Enter to continue..."
read
;;
 
13)
clear
echo "====================================="
echo " 13 - Version Info                   "
echo "====================================="
echo
fn_version_info
echo
echo " Press Enter to continue..."
read
;;

14)
clear
while true
do
echo "====================================="
echo " 14 - Backup Status                  "
echo "====================================="
echo
fn_backup_status
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read IMSI_ANSWER
if [ "$IMSI_ANSWER" == 'q' ]
then
        break
else
        clear
fi
done
;;

15)
clear
echo "====================================="
echo " 15 - fn_volume_location                "
echo "====================================="
echo
fn_volume_location 
echo
echo " Press Enter to continue..."
read
;;

# 2.DataBase -----------------------------------

21)
clear
echo "====================================="
echo " 21 - Database Status                "
echo "====================================="
echo
fn_database_status
echo
echo " Press Enter to continue..."
read
;;

22)
clear
while true
do
echo "====================================="
echo " 22 - Database Space                 "
echo "====================================="
echo
fn_database_space
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read IMSI_ANSWER
if [ "$IMSI_ANSWER" == 'q' ]
then
        break
else
        clear
fi
done
;;

23)
clear
echo "====================================="
echo " 23 - Database config                "
echo "====================================="
echo
fn_database_config
echo
echo " Press Enter to continue..."
read
;;

24)
clear
while true
do
echo "====================================="
echo " 24 - User Info                    "
echo "====================================="
echo
fn_user_info
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read IMSI_ANSWER
if [ "$IMSI_ANSWER" == 'q' ]
then
        break
else
        clear
fi
done
;;

25)
clear
while true
do
echo "====================================="
echo " 25 - Database Statistics            "
echo "====================================="
echo
fn_database_statdump
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read IMSI_ANSWER
if [ "$IMSI_ANSWER" == 'q' ]
then
        break
else
        clear
fi
done
;;


# 3.Broker -------------------------------------

31)
clear
echo "====================================="
echo " 31 - Broker status                  "
echo "====================================="
echo
fn_broker_status
echo
;;

32)
clear
while true
do
echo "====================================="
echo " 32 - Broker status(detail)          "
echo "====================================="
echo
fn_broker_status_detail
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
;;

33)
clear
while true
do
	echo "====================================="
	echo " 33 - Broker config                  "
	echo "====================================="
	echo
	fn_broker_config
	echo
	echo
	echo "====================================="
	echo " Press 'q' to Finish."
	echo " Press Enter to continue."
	echo "====================================="
	read answer
	if [ "$answer" == 'q' ]
	then
	        break
	else
	        clear
	fi
done
;;

34)
clear
while true
do
fn_broker_log_top
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read IMSI_ANSWER
if [ "$IMSI_ANSWER" == 'q' ]
then
        break
else
        clear
fi
done
;;

# 4.HA -----------------------------------------


41)
clear
echo "====================================="
echo " 41 - HA Status                      "
echo "====================================="
echo
fn_ha_status | more
echo
echo " Press Enter to continue..."
read
;;

42)
clear
while true
do
echo "====================================="
echo " 42 - HA Apply info                  "
echo "====================================="
echo
fn_ha_apply_info
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read IMSI_ANSWER
if [ "$IMSI_ANSWER" == 'q' ]
then
        break
else
        clear
fi
done
;;


43)
clear
while true
do
echo "====================================="
echo " 43 - HA Warning                     "
echo "====================================="
echo
fn_ha_warning
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read IMSI_ANSWER
if [ "$IMSI_ANSWER" == 'q' ]
then
        break
else
        clear
fi
done
;;


44)
clear
echo "====================================="
echo " 44 - HA config                      "
echo "====================================="
echo
fn_ha_config
echo
echo " Press Enter to continue..."
read
;;

# 5. Transction / Lock

51)
clear
while true
do
echo "====================================="
echo " 51 - Transaction status             "
echo "====================================="
echo
fn_transaction_status
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read IMSI_ANSWER
if [ "$IMSI_ANSWER" == 'q' ]
then
        break
else
        clear
fi
done
;;

52)
clear
while true
do
echo "====================================="
echo " 52 - Lock status                    "
echo "====================================="
echo
fn_lock_status
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read IMSI_ANSWER
if [ "$IMSI_ANSWER" == 'q' ]
then
        break
else
        clear
fi
done
;;


# 6.OTHER --------------------------------------

61)
clear
echo "====================================="
echo " 61 - CSQL                           "
echo "====================================="
echo
fn_csql
;;

62)
clear
while true
do
echo "====================================="
echo " 62 - Table Size Info                "
echo "====================================="
echo
fn_table_size_info
echo
echo
echo "====================================="
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo "====================================="
read IMSI_ANSWER
if [ "$IMSI_ANSWER" == 'q' ]
then
        break
else
        clear
fi
done
;;

# 7.HELP ---------------------------------------

71)
clear
echo "====================================="
echo " 71 - Restart                        "
echo "====================================="
echo
echo "-------------------------------------------------"
echo " Start command help                              "
echo "-------------------------------------------------"
echo " 1. Single                                       "
echo "     Step1. Server     : cubrid server start database-name"
echo "     Step2. broker     : cubrid broker start        "
echo "     Step3. manager    : cubrid manager start       "
echo
echo " 2. HA(Master -> Slave)                             "
echo "     Step1. HA-Server  : cubrid hb start            "
echo "     Step2. broker     : cubrid broker start        "
echo "     Step3. manager    : cubrid manager start       "
echo "-------------------------------------------------"
echo
echo
echo "-------------------------------------------------"
echo " Stop command help                               "
echo "-------------------------------------------------"
echo " 1. Single                                       "
echo "     Step1. manager    : cubrid manager stop        "
echo "     Step2. broker     : cubrid broker stop         "
echo "     Step3. Server     : cubrid server stop database-name "
echo
echo " 2. HA(Slave -> Master)                             "
echo "     Step1. manager    : cubrid manager stop        "
echo "     Step2. broker     : cubrid broker stop         "
echo "     Step3. HA-Server  : cubrid hb stop             "
echo "-------------------------------------------------"
echo
echo " Press Enter to continue..."
read
;;

72)
clear
echo "====================================="
echo " 72 - Add Volume                     "
echo "====================================="
echo
echo "-------------------------------------------------"
echo " Add Volume command help                         "
echo "-------------------------------------------------"
echo " 1. usage   : cubrid addvoldb [OPTION] database-name"
echo
echo " 2. option  :                                    "
echo "             --db-volume-size=SIZE        size of additional volume; default: db_volume_size in cubrid.conf"
echo "             --max-writesize-in-sec=SIZE  the amount of volume written per second; (ex. 512K, 1M, 10M); default: not used; minimum: 160K"
echo "             -n, --volume-name=NAME       NAME of information volume; default: generate such as "db"_ext1)"
echo "             -F, --file-path=PATH         PATH for adding volume file; default: working directory"
echo "             --comment=COMMENT            COMMENT for adding volume file; default: none"
echo "             -p, --purpose=PURPOSE        PURPOSE for adding volume file; allowed:"
echo "                                                  DATA - only for data"
echo "                                                  INDEX - only for indices"
echo "                                                  TEMP - only for temporary"
echo "                                                  GENERIC - for all purposes"
echo "             -S, --SA-mode                stand-alone mode execution"
echo "             -C, --CS-mode                client-server mode execution"
echo
echo " 3. example :                                    "
echo "    3-1 Single                                   "
echo "        1) DATA  : cubrid addvoldb -p data --db-volume-size=1G database-name "
echo "        2) INDEX : cubrid addvoldb -p index --db-volume-size=1G database-name "
echo "        3) TEMP  : cubrid addvoldb -p temp --db-volume-size=1G database-name "
echo
echo "    3-2 HA-Server                                "
echo "        1) DATA  : cubrid addvoldb -p data --db-volume-size=1G database-name@localhost"
echo "        2) INDEX : cubrid addvoldb -p index --db-volume-size=1G database-name@localhost"
echo "        3) TEMP  : cubrid addvoldb -p temp --db-volume-size=1G database-name@localhost "
echo
echo "    3-3 Stand-alone mode(DB is not Running)      "
echo "        1) DATA  : cubrid addvoldb -S -p data --db-volume-size=1G database-name"
echo "        2) INDEX : cubrid addvoldb -S -p index --db-volume-size=1G database-name"
echo "        3) TEMP  : cubrid addvoldb -S -p temp --db-volume-size=1G database-name"
echo
echo " Press Enter to continue..."
read
;;

73)
clear
echo "====================================="
echo " 83 - HA Warning Help                "
echo "====================================="
echo
echo "-------------------------------------------------"
echo "  Remove Serial Cache help                       "
echo "-------------------------------------------------"
echo " 1. Serial Cache List Check                      "
echo "    - select * from db_serial where cached>num>0;"
echo " 2. Remove Serial Cache                          "
echo "    - alter serial <serial-name> nocache;         "
echo " 3. Remove Check                                 "
echo "    - select name, cached_num from db_serial where name='<serial_name>';"
echo "-------------------------------------------------"
echo
echo 
echo "-------------------------------------------------"
echo "  Conversion From CLOB To Varchar help           "
echo "-------------------------------------------------"
echo " 1. Clob List Check                              "
echo "    - select class_name, attr_name, data_type from db_attribute where data_type='CLOB';"
echo " 2. Conversion From Clob To Varchar              "
echo "     Step 1. add column Varchar                  "
echo "      - alter table <table_name> add column <new_column_name> varchar; "
echo "     Step 2. Conversion Clob_to_char             "
echo "      - update <table_name> set <new_column_name>=CLOB_TO_CHAR(old_column_name>;"
echo "     Step 3. drop column clob                    "
echo "      - alter table <table_name> drop column <old_column_name>;"
echo "     Step 4. rename column                       "
echo "      - alter table <table_name> rename column <new_column_name> as <old_column_name>;"
echo "-------------------------------------------------"
echo
echo
echo "-------------------------------------------------"
echo "  Conversion From BLOB To Bit varying help       "
echo "-------------------------------------------------"
echo " 1. Blob List Check                              "
echo "    - select class_name, attr_name, data_type from db_attribute where data_type='BLOB';"
echo " 2. Conversion From Blob To Bit varying          "
echo "     Step 1. add column Bit varying              "
echo "      - alter table <table_name> add column <new_column_name> bit varying;"
echo "     Step 2. Conversion Blob_to_bit varying      "
echo "      - update <table_name> set <new_column_name>=BLBO_TO_BIT(old_column_name>;"
echo "     Step 3. drop column blob                    "
echo "      - alter table <table_name> drop column <old_column_name>;"
echo "     Step 4. rename column                       "
echo "      - alter table <table_name> rename column <new_column_name> as <old_column_name>;"
echo "-------------------------------------------------"
echo

echo " Press Enter to continue..."
read
;;

0)
clear
break
;;

00)
clear
break
;;


q)
clear
break
;;
esac

done


