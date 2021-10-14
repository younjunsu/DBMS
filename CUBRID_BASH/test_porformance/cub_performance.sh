#!/bin/bash
####################################################################################################################
#### [START] USER configuration.
## Collection Linux User (DB ENGINE)
# [EX] DB_ENGINE_USER=cubrid
DB_ENGINE_USER=cubrid939

## Collection DB Name
# [EX] DB_NAME=demodb
DB_NAME=cub_db_junsu

## Collection Broker
# [EX] BROKER_NAME=query_editor
BROKER_NAME=broker1

## SQLITE3
# [EX] SQLITE3=/home/cubrid/db_volume
LOGDB_PATH=/NIRS/cubrid939/CUBRID/tmp/performance_junsu/sqlite3_volume
UTIL_LOGDB="sqlite3"

## SHELL Scripts Interval
# [EX] INTERVAL_SEC=3 = function performance_server 
# [EX] INTERVAL_DAY=1 = function performance_disk and performance_volume
INTERVAL_SEC=5
INTERVAL_DAY=1

#### [END] USER configuration.

####################################################################################################################
#### [START] Program Utility Checking
UTIL_CHECK_LSOF=`lsof 2>/dev/null |head -n 1 ` 

if [ $UTIL_CHECK_LSOF -z ] 2>/dev/null ; then
	echo "> ERROR : lsof 명령어를 사용할 수 없습니다. "
	exit
fi

#### [END] Program Utility Checking



####################################################################################################################
#### [START] USER configuration
function fn_user_config_check_output(){
	printf "> DB_ENGINE_USER : $DB_ENGINE_USER \n"
	printf "> DB_NAME        : $DB_NAME \n"
	printf "> BROKER_NAME    : $BROKER_NAME \n"
	printf "> UTIL_LOGDB     : $UTIL_LOGDB \n"
	printf "> LOGDB_PATH     : $LOGDB_PATH \n"
	printf "> INTERVAL_SEC   : $INTERVAL_SEC (sec)\n"
	printf "> INTERVAL_DAY   : $INTERVAL_DAY (day)\n"
	
	echo
	echo -n "# Select Y (Run) or N (Stop) : "
	
	read USER_CONF_CHK_INPUT
	
	if [ $USER_CONF_CHK_INPUT = "y" ] || [ $USER_CONF_CHK_INPUT = "Y" ] || [ $USER_CONF_CHK_INPUT = "YES" ] || [ $USER_CONF_CHK_INPUT = "yes" ]; then
		2>/dev/null
	else
		exit
	fi
	
}
#### [END] USER configuration

####################################################################################################################
#### [START] USER configuration.
function fn_user_config_check(){
	if [ $DB_ENGINE_USER -z ] || [ $DB_NAME -z ] || [ $BROKER_NAME -z ] || [ $LOGDB_PATH -z ] || [ $INTERVAL_SEC -z ] || [ $INTERVAL_DAY -z] || [ $INTERVAL_DAY <= 0 ]; then
		if [ $DB_ENGINE_USER -z ]; then
			echo "> ERROR : DB_ENGINE_USER 변수 설정이 되어 있지 않습니다." 
			echo
		fi

		if [ $DB_NAME -z ]; then
			echo "> ERROR : DB_NAME 변수 설정이 되어 있지 않습니다."
			echo
		fi 

		if [ $BROKER_NAME -z ]; then
			echo "> ERROR : BROKER_NAME 변수 설정이 되어 있지 않습니다."
			echo
		fi

		if [ $LOGDB_PATH -z ]; then
			echo "> ERROR : LOGDB_PATH 변수 설정이 되어 있지 않습니다."
			echo
		fi
		
		if [ $INTERVAL_SEC -z ]; then
			echo "> ERROR : INTERVAL_SEC 변수 설정이 되어 있지 않습니다."
			echo
		fi
		
		if [ $INTERVAL_DAY -z ]; then
			echo "> ERROR : INTERVAL_DAY 변수 설정이 되어 있지 않습니다."
			echo
		fi
		
		if [ $INTERVAL_DAY <= 0 ]; then
			echo "> ERROR : INTERVAL_DAY 값은 0 보다 커야 합니다."
			echo
		fi
		exit
	fi

}
#### [END] USER configuration.


####################################################################################################################
#### [START] CUBRID environment variables.
function fn_cubrid_env(){
	NODAT_CUB=`ls ~/cubrid.sh`
	DAT_CUB=`ls ~/.cubrid.sh`

	if [ $DAT_CUB -z ]; then
		if [ $NODAT_CUB -z ]; then
			echo "> ERROR : 큐브리드가 설치 되어 있지 않거나, 큐브리드 환경 변수를 확인 하십시요."
			echo "       (큐브리드 환경 변수 파일 : cubrid.sh 또는 .cubrid.sh)"
			echo
			exit
		else
			. ~/cubrid.sh
		fi
	else
		. ~/.cubrid.sh
	fi
}

function fn_version_check(){
	VERSION_9_CHECK=`cubrid_rel |sed '/^$/d' |awk '{print $2}' |sed 's/\.[0-9]//g'`
	VERSION_10_CHECK=`cubrid_rel |sed '/^$/d' |awk '{print $2}' |sed 's/\.[0-9]//g'`
	
	if [ $VERSION_9_CHECK -z -o $VERSION_10_CHECK -z ]; then
		echo "> ERROR : 큐브리드 버전을 확인 할 수 없습니다. "
		echo
		exit
	elif [ $VERSION_9_CHECK = "9" ]; then
			CUBRID_VERSION="9"
	elif [ $VERSION_10_CHECK = "10" ]; then
			CUBRID_VERSION="10"
	fi
}

function fn_cubrid_process_check(){
	CUBRID_DB_CHECK=`cubrid server status |grep -w "$DB_NAME" `
	CUBRID_BRO_CHECK=`cubrid broker status -b |grep -w "$BROKER_NAME"`
	LOGDB_PATH_CHECK=`ls $LOGDB_PATH`
	#LOGDB_CHECK=`sqlite3 --version`
	
	if [ $CUBRID_DB_CHECK -z ] || [ $CUBRID_BRO_CHECK -z ] || [ $LOGDB_PATH_CHECK -z ]; then
		if [ $CUBRID_DB_CHECK -z ]; then
			echo "> ERROR : CUBRID  DB:$DB_NAME Running CHECKING"
		fi
		
		if [ $CUBRID_BRO_CHECK -z ]; then
			echo "> ERROR : CUBRID BROKER:$BROKER_NAME Running CHECKING"
		fi
		
		if [ $LOGDB_PATH_CHECK -z ]; then
			echo "> ERROR : LOG DB PATH:$LOGDB_PATH CHECKING"
		fi
		exit
	fi
}
#### [END] CUBRID environment variables.



####################################################################################################################
#### [START] Program variables

	
	
	#UTIL_RESOURCE="top -b -n 1 -p 1"
	UTIL_MEM="free -m"
	UTIL_CUB_STATDUMP="cubrid statdump"
	UTIL_CUB_SERVER_STATUS="cubrid server status"
	UTIL_CUB_BROKER="cubrid broker status -b |grep -w $BROKER_NAME"	
	UTIL_CUB_BROKER_BUSY="cubrid broker status -b -f |grep -w $BROKER_NAME"
	UTIL_CUB_SPACEDB="cubrid spacedb --size-unit=m -s $DB_NAME@localhost"
	
function fn_current_date(){
	UTIL_CURRENT_DATE=`date +%Y-%m-%d" "%H:%M:%S" "%u`
	UTIL_CURRENT_DAY=`echo $UTIL_CURRENT_DATE |awk '{print $1}'`
	UTIL_CURRENT_HMS=`echo $UTIL_CURRENT_DATE |awk '{print $2}'`
	UTIL_CURRENT_WEEK=`echo $UTIL_CURRENT_DATE |awk '{print $3}'`
}
#### [END] Program variables


####################################################################################################################
#### [START] Table Checking.
function fn_logdb_tables_check(){
	LOGDB_TABLE_CHECK=`$UTIL_LOGDB  $LOGDB_PATH "SELECT type,name,tbl_name \
																								FROM   sqlite_master      \
																								WHERE  type='table'       \
																								AND tbl_name LIKE 'performance_%' \
																								AND tbl_name LIKE 'PERFORMANCE_%';"`
	
	LOGDB_TABLE_PERFORMANCE_SERVER=`echo "$LOGDB_TABLE_CHECK" |grep -i "performance_server"`
	LOGDB_TABLE_PERFORMANCE_VOLUME=`echo "$LOGDB_TABLE_CHECK" |grep -i "performance_volume"`
	LOGDB_TABLE_PERFORMANCE_DISK=`echo "$LOGDB_TABLE_CHECK" |grep -i "performance_disk"`
	LOGDB_TABLE_PERFORMANCE_PROCESS=`echo "$LOGDB_TABLE_CHECK" |grep -i "performance_process"`
	
	if [ $LOGDB_TABLE_PERFORMANCE_SERVER -z ] || [ $LOGDB_TABLE_PERFORMANCE_VOLUME -z ] || [ $LOGDB_TABLE_PERFORMANCE_DISK -z ] || [ $LOGDB_TABLE_PERFORMANCE_PROCESS -z ] ; then
		if [ $LOGDB_TABLE_PERFORMANCE_SERVER -z ]; then
			echo "> ERROR : Unknown PERFORMANCE_SERVER Table"
			echo "	Create a \"PERFORMANCE_SERVER\" table. "
		
			$UTIL_LOGDB  $LOGDB_PATH "CREATE TABLE PERFORMANCE_SERVER( \
	    DATE_DAY VARCHAR(15) NOT NULL, DATE_HMS VARCHAR(15) NOT NULL, \
	    DATE_WEEK INT NOT NULL, CPU_USED FLOAT NOT NULL, \
	    CPU_LOAD FLOAT NOT NULL, IO_WAIT FLOAT NOT NULL, \
	    MEM_TOTAL FLOAT NOT NULL, MEM_USED FLOAT NOT NULL, \
	    MEM_FREE FLOAT NOT NULL, MEM_CALC FLOAT NOT NULL, \
	    MEM_SWAP_TOTAL FLOAT NOT NULL, MEM_SWAP_USED FLOAT NOT NULL, \
	    MEM_SWAP_FREE FLOAT NOT NULL, MEM_SWAP_CALC FLOAT NOT NULL, \
	    DB_BUFFER_HIT FLOAT NOT NULL, DB_TEMP_USED FLOAT NOT NULL, \
	    BROKER_PID INT NOT NULL, BROKER_AS INT NOT NULL, \
	    BROKER_JQ INT NOT NULL, BROKER_TPS INT NOT NULL, \
	    BROKER_QPS INT NOT NULL, BROKER_SELECT INT NOT NULL, \
	    BROKER_INSERT INT NOT NULL, BROKER_UPDATE INT NOT NULL, \
	    BROKER_DELETE INT NOT NULL, BROKER_OTHERS INT NOT NULL, \
	    BROKER_LONGT INT NOT NULL, BROKER_LONGQ INT NOT NULL, \
	    BROKER_ERRQ INT NOT NULL, BROKER_CONNECT INT NOT NULL, \
	    BROKER_REJECT INT NOT NULL, \
	    BROKER_BUSY INT NOT NULL, \
	    CONSTRAINT pk_performance_server_date_day_date_hms PRIMARY KEY(DATE_DAY,DATE_HMS));"
		fi
		
		if [ $LOGDB_TABLE_PERFORMANCE_VOLUME -z ]; then
			echo "> ERROR : Unknown PERFORMANCE_VOLUME Table"
			echo "	Create a \"PERFORMANCE_VOLUME\" table. "
		
			$UTIL_LOGDB  $LOGDB_PATH "CREATE TABLE PERFORMANCE_VOLUME( \
			DATE_DAY VARCHAR(15) NOT NULL, DATE_HMS VARCHAR(15) NOT NULL, \
			DATE_WEEK INT NOT NULL, VOL_TYPE VARCHAR(10) NOT NULL, \
			TOT_SIZE FLOAT NOT NULL, USED_SIZE FLOAT NOT NULL, \
			FREE_SIZE FLOAT NOT NULL, \
			CONSTRAINT pk_performance_volume_date_day_date_hms_vol_type PRIMARY KEY(DATE_DAY,DATE_HMS,VOL_TYPE));"
		fi
		
		if [ $LOGDB_TABLE_PERFORMANCE_DISK -z ]; then
			echo "> ERROR : Unknown PERFORMANCE_DISK Table"
			echo "	Create a \"PERFORMANCE_DISK\" table. "
			
			$UTIL_LOGDB  $LOGDB_PATH "CREATE TABLE PERFORMANCE_DISK( \
			DATE_DAY VARCHAR(15) NOT NULL, DATE_HMS VARCHAR(15) NOT NULL, \
			DATE_WEEK INT NOT NULL, DB_MODE VARCHAR(5) NOT NULL, \
			DATA_TYPE VARCHAR(7) NOT NULL, DATA_PATH VARCHAR(20) NOT NULL, \
			DISK_TOT_SIZE INT NOT NULL, DISK_USED_SIZE INT NOT NULL, \
			DISK_DATA_CALC INT VARCHAR(5), \
			CONSTRAINT pk_performance_disk_date_day_date_hms_data_type PRIMARY KEY(DATE_DAY,DATE_HMS,DATA_TYPE));"
		fi
	  
	  if [ $LOGDB_TABLE_PERFORMANCE_PROCESS -z ]; then
			echo "> ERROR : Unknown PERFORMANCE_PROCESS Table"
			echo "	Create a \"PERFORMANCE_PROCESS\" table. "
		
			$UTIL_LOGDB  $LOGDB_PATH "CREATE TABLE PERFORMANCE_PROCESS( \
			DATE_DAY VARCHAR(15) NOT NULL, \
	    DATE_HMS VARCHAR(15) NOT NULL, \
	    DATE_WEEK INT NOT NULL, \
			CUB_PID VARCHAR(15) NOT NULL, \
			CUB_CPU_USED VARCHAR(15) NOT NULL, \
			CUB_MEM_USED VARCHAR(15) NOT NULL, \
			PER_PRO_NUM1_CMD VARCHAR(15), \
			PER_PRO_NUM1_CPU_USED VARCHAR(15), \
			PER_PRO_NUM1_MEM_USED VARCHAR(15), \
			PER_PRO_NUM2_CMD VARCHAR(15), \
			PER_PRO_NUM2_CPU_USED VARCHAR(15), \
			PER_PRO_NUM2_MEM_USED VARCHAR(15), \
			PER_PRO_NUM3_CMD VARCHAR(15), \
			PER_PRO_NUM3_CPU_USED VARCHAR(15), \
			PER_PRO_NUM3_MEM_USED VARCHAR(15), \
			PER_PRO_NUM4_CMD VARCHAR(15), \
			PER_PRO_NUM4_CPU_USED VARCHAR(15), \
			PER_PRO_NUM4_MEM_USED VARCHAR(15), \
			PER_PRO_NUM5_CMD VARCHAR(15), \
			PER_PRO_NUM5_CPU_USED VARCHAR(15), \
			PER_PRO_NUM5_MEM_USED VARCHAR(15), \
			CONSTRAINT pk_performance_process_date_day_date_hms PRIMARY KEY(DATE_DAY,DATE_HMS));"
		fi
	  
	  LOGDB_TABLE_CHECK=`$UTIL_LOGDB  $LOGDB_PATH "SELECT type,name,tbl_name \
																								FROM   sqlite_master      \
																								WHERE  type='table'       \
																								AND tbl_name LIKE 'performance_%' \
																								AND tbl_name LIKE 'PERFORMANCE_%';"`
																								
		LOGDB_TABLE_PERFORMANCE_SERVER=`echo "$LOGDB_TABLE_CHECK" |grep -i "performance_server"`
		LOGDB_TABLE_PERFORMANCE_VOLUME=`echo "$LOGDB_TABLE_CHECK" |grep -i "performance_volume"`
		LOGDB_TABLE_PERFORMANCE_DISK=`echo "$LOGDB_TABLE_CHECK" |grep -i "performance_disk"`
		LOGDB_TABLE_PERFORMANCE_PROCESS=`echo "$LOGDB_TABLE_CHECK" |grep -i "performance_process"`
		
		if [ $LOGDB_TABLE_PERFORMANCE_SERVER -z ] || [ $LOGDB_TABLE_PERFORMANCE_VOLUME -z ] || [ $LOGDB_TABLE_PERFORMANCE_DISK -z ] || [ $LOGDB_TABLE_PERFORMANCE_PROCESS -z ] ; then
			echo "> ERROR : $UTIL_LOGDB Please Checking "
			exit
		fi
	fi					
}
#### [END] Table Checking.


####################################################################################################################
#### [START] Program Functions 
function fn_performance_server_resource_info(){
	UTIL_RESOURCE=`top -b -n 2 -d $INTERVAL_SEC`
	
	# USED 100.00 - idle
	PER_SV_CPU_FREE=`echo "$UTIL_RESOURCE" |grep "Cpu" |tail -n 1 |sed 's/%/ /g' |awk '{print $(NF-9)}'`
	PER_SV_CPU_USED=`echo 100.00 - $PER_SV_CPU_FREE |bc`
	PER_SV_CPU_LOAD=`echo "$UTIL_RESOURCE"  |grep "load average:" |tail -n 1 |awk '{print $(NF-2)}' |sed 's/,//g'`
	PER_SV_IO_WAIT=`echo "$UTIL_RESOURCE" |grep "Cpu" |tail -n 1 |sed 's/%/ /g' |awk '{print $(NF-7)}'`

	## Total 값
	# KB에서 MB 단위 변환
	
	##top: procps version 3.2.7
	#Mem:   8166548k total,  8117236k used,    49312k free,   190988k buffers
	#Swap:  4096564k total,  1937796k used,  2158768k free,   534980k cached

	##top: procps-ng version 3.3.10
	#KiB Mem :  7997540 total,  7540780 free,   181532 used,   275228 buff/cache
	#KiB Swap:  8257532 total,  8257532 free,        0 used.  7577188 avail Mem
	
	PER_SV_MEM_ARRAY=(`echo "$UTIL_RESOURCE" |grep -v "Swap" |grep "Mem" |tail -n 1 |sed 's/k/ /g' |sed 's/KiB//g'|sed 's/ //g' |sed 's/,/ /g'|sed 's/:/ /g'|sed 's/\./ /'`)
	
	for PER_SV_MEM_ARRAY_CHECK in ${PER_SV_MEM_ARRAY[@]}
		do
			MEM_TOTAL=`echo $PER_SV_MEM_ARRAY_CHECK |grep "total"`
			MEM_USED=`echo $PER_SV_MEM_ARRAY_CHECK |grep "used"`
		  MEM_FREE=`echo $PER_SV_MEM_ARRAY_CHECK |grep "free"`
			
			if [ $MEM_TOTAL -z ];then
				2>/dev/null
			else
				# Memory Total
				PER_SV_MEM_TOTAL=`echo $MEM_TOTAL |sed 's/total//g'`
				PER_SV_MEM_TOTAL=`echo "$PER_SV_MEM_TOTAL / 1024" |bc`
			fi

		    if [ $MEM_USED -z ];then
				2>/dev/null
			else
				# Memory USED
				PER_SV_MEM_USED=`echo $MEM_USED |sed 's/used//g'`
				PER_SV_MEM_USED=`echo "$PER_SV_MEM_USED / 1024" |bc`
			fi	

		    if [ $MEM_FREE -z ];then
				2>/dev/null
			else
				# Memory Free
				PER_SV_MEM_FREE=`echo $MEM_FREE |sed 's/free//g'`
				PER_SV_MEM_FREE=`echo "$PER_SV_MEM_FREE / 1024" |bc`
			fi
		done
	
	## MEM 사용량 
	PER_SV_MEM_CALC=`echo "$PER_SV_MEM_USED * 100 / $PER_SV_MEM_TOTAL" |bc`

###########SWAP

	PER_SV_MEM_SWAP_ARRAY=(`echo "$UTIL_RESOURCE" |grep "Swap" |tail -n 1 |sed 's/k/ /g' |sed 's/KiB//g'|sed 's/ //g' |sed 's/,/ /g'|sed 's/:/ /g'|sed 's/\./ /'`)
	
	
	for PER_SV_MEM_SWAP_ARRAY_CHECK in ${PER_SV_MEM_SWAP_ARRAY[@]}
		do
			MEM_SWAP_TOTAL=`echo $PER_SV_MEM_SWAP_ARRAY_CHECK |grep "total"`
			MEM_SWAP_USED=`echo $PER_SV_MEM_SWAP_ARRAY_CHECK |grep "used"`
		  MEM_SWAP_FREE=`echo $PER_SV_MEM_SWAP_ARRAY_CHECK |grep "free"`
			
			if [ $MEM_SWAP_TOTAL -z ];then
				2>/dev/null
			else
				# SWAP Memory Total
				PER_SV_MEM_SWAP_TOTAL=`echo $MEM_SWAP_TOTAL |sed 's/total//g'`
				PER_SV_MEM_SWAP_TOTAL=`echo "$PER_SV_MEM_SWAP_TOTAL / 1024" |bc`
			fi

		    if [ $MEM_SWAP_USED -z ];then
				2>/dev/null
			else
				# SWAP Memory USED
				PER_SV_MEM_SWAP_USED=`echo $MEM_SWAP_USED |sed 's/used//g'`
				PER_SV_MEM_SWAP_USED=`echo "$PER_SV_MEM_SWAP_USED / 1024" |bc`
			fi	

		    if [ $MEM_SWAP_FREE -z ];then
				2>/dev/null
			else
				# SWAP Memory Free
				PER_SV_MEM_SWAP_FREE=`echo $MEM_SWAP_FREE |sed 's/free//g'`
				PER_SV_MEM_SWAP_FREE=`echo "$PER_SV_MEM_SWAP_FREE / 1024" |bc`
			fi
		done
	
	## SWAP MEM 사용량 
	PER_SV_MEM_SWAP_CALC=`echo "$PER_SV_MEM_SWAP_USED * 100 / $PER_SV_MEM_SWAP_TOTAL" |bc`
	
	## STATDUMP Buffer Hit Ratio
	PER_SV_BUFFER_HIT=`$UTIL_CUB_STATDUMP $DB_NAME@localhost |grep "Data_page_buffer_hit_ratio" |awk '{print $3}'`
	
	if [ $PER_SV_MEM_CALC -z ]; then
		PER_SV_MEM_CALC=0
	elif [ $PER_SV_MEM_SWAP_CALC -z ]; then
		PER_SV_MEM_SWAP_CALC=0
	fi
	
	
	UTIL_CUB_SPACEDB=`cubrid spacedb --size-unit=g -s $DB_NAME@localhost`
	
	if [ $CUBRID_VERSION = "9" ];then
			## SPACEDB TEMP 사용량
			PER_SV_TEMP_USED=`echo "$UTIL_CUB_SPACEDB" |grep -v "TEMP TEMP" |grep "TEMP"|awk '{print $4}'`
			PER_SV_TEMP_TEMP_USED=`echo "$UTIL_CUB_SPACEDB" |grep  "TEMP TEMP"|awk '{print $5}'`
			PER_SV_TEMP_USED_RESULT=`echo "$PER_SV_TEMP_USED + $PER_SV_TEMP_TEMP_USED"|bc`
	elif [ $CUBRID_VERSION = "10" ];then
			PER_SV_TEMP_USED=`echo "$UTIL_CUB_SPACEDB" |grep -w "PERMANENT" |grep "TEMPORARY DATA" |awk '{print $5}'`
			PER_SV_TEMP_TEMP_USED=`echo "$UTIL_CUB_SPACEDB" |grep -v "PERMANENT" |grep -w "TEMPORARY"|awk '{print $5}'`
			PER_SV_TEMP_USED_RESULT=`echo "$PER_SV_TEMP_USED + $PER_SV_TEMP_TEMP_USED"|bc`
	fi	
	
	
	
}

function fn_performance_server_broker(){
	UTIL_CUB_BROKER=`cubrid broker status -b |grep -w $BROKER_NAME`
	UTIL_CUB_BROKER_BUSY=`cubrid broker status -b -f |grep -w $BROKER_NAME`
	## BROKER STATUS
	PER_SV_BRO_PID=`echo "$UTIL_CUB_BROKER" |awk '{print $3}'`
	PER_SV_BRO_AS=`echo "$UTIL_CUB_BROKER" |awk '{print $5}'`
	PER_SV_BRO_JQ=`echo "$UTIL_CUB_BROKER" |awk '{print $6}'`
	PER_SV_BRO_TPS=`echo "$UTIL_CUB_BROKER" |awk '{print $7}'`
	PER_SV_BRO_QPS=`echo "$UTIL_CUB_BROKER" |awk '{print $8}'`
	PER_SV_BRO_SELECT=`echo "$UTIL_CUB_BROKER" |awk '{print $9}'`
	PER_SV_BRO_INSERT=`echo "$UTIL_CUB_BROKER" |awk '{print $10}'`
	PER_SV_BRO_UPDATE=`echo "$UTIL_CUB_BROKER" |awk '{print $11}'`
	PER_SV_BRO_DELETE=`echo "$UTIL_CUB_BROKER" |awk '{print $12}'`
	PER_SV_BRO_OTHERS=`echo "$UTIL_CUB_BROKER" |awk '{print $13}'`
	PER_SV_BRO_LONGT=`echo "$UTIL_CUB_BROKER" |awk '{print $14}' |sed 's/\/.*//g'`
	PER_SV_BRO_LONGQ=`echo "$UTIL_CUB_BROKER" |awk '{print $15}' |sed 's/\/.*//g'`
	PER_SV_BRO_ERRQ=`echo "$UTIL_CUB_BROKER" |awk '{print $16}'`
	PER_SV_BRO_CONNECT=`echo "$UTIL_CUB_BROKER" |awk '{print $18}'`
	PER_SV_BRO_REJECT=`echo "$UTIL_CUB_BROKER" |awk '{print $19}'`
	PER_SV_BRO_BUSY=`echo $UTIL_CUB_BROKER_BUSY |awk '{print $8}'`
}

function fn_performance_process(){
	
	PER_PRO_PID=`cubrid server status |grep -w $DB_NAME |sed 's/)//g' |awk '{print $NF}'`
	PER_PRO_CPU_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |sed 's/--/junsuyoun/g' |grep -A11 "junsuyoun" |grep -A10 "PID USER" |grep "cub_server" |grep -w $PER_PRO_PID |awk '{print $9}'`
	PER_PRO_MEM_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |sed 's/--/junsuyoun/g' |grep -A11 "junsuyoun" |grep -A10 "PID USER" |grep "cub_server" |grep -w $PER_PRO_PID |awk '{print $10}'`
	PER_PRO_CPU_CNT=`cat /proc/cpuinfo |grep "processor" |wc -l`
	
	if [ $PER_PRO_CPU_USED -z ]; then
		PER_PRO_CPU_USED=0
	fi
	
	if [ $PER_PRO_MEM_USED -z ]; then
		PER_PRO_MEM_USED=0
	fi
	
	PER_PRO_CPU_AVG=`echo "$PER_PRO_CPU_USED / $PER_PRO_CPU_CNT" |bc`
	

	#top -b -n 2 |head -n 20|grep -v "grep" |grep -A10 "PID USER" |grep -v "PID USER" |head -n 1
	
	PER_PRO_NUM1_CPU_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 1p |awk '{print $9}'`
	PER_PRO_NUM1_MEM_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 1p |awk '{print $10}'`
	PER_PRO_NUM1_CMD=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 1p |awk '{print $12}'`
	PER_PRO_NUM1_CPU_AVG=`echo "$PER_PRO_NUM1_CPU_USED / $PER_PRO_CPU_CNT" |bc`
	
	PER_PRO_NUM2_CPU_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 2p |awk '{print $9}'`
	PER_PRO_NUM2_MEM_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 2p |awk '{print $10}'`
	PER_PRO_NUM2_CMD=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 2p |awk '{print $12}'`
	PER_PRO_NUM2_CPU_AVG=`echo "$PER_PRO_NUM2_CPU_USED / $PER_PRO_CPU_CNT" |bc`
		
	PER_PRO_NUM3_CPU_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 3p |awk '{print $9}'`
	PER_PRO_NUM3_MEM_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 3p |awk '{print $10}'`
	PER_PRO_NUM3_CMD=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 3p |awk '{print $12}'`
	PER_PRO_NUM3_CPU_AVG=`echo "$PER_PRO_NUM3_CPU_USED / $PER_PRO_CPU_CNT" |bc`
	
	PER_PRO_NUM4_CPU_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 4p |awk '{print $9}'`
	PER_PRO_NUM4_MEM_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 4p |awk '{print $10}'`
	PER_PRO_NUM4_CMD=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 4p |awk '{print $12}'`
	PER_PRO_NUM4_CPU_AVG=`echo "$PER_PRO_NUM4_CPU_USED / $PER_PRO_CPU_CNT" |bc`
	
	PER_PRO_NUM5_CPU_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 5p |awk '{print $9}'`
	PER_PRO_NUM5_MEM_USED=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 5p |awk '{print $10}'`
	PER_PRO_NUM5_CMD=`echo "$UTIL_RESOURCE" |grep -A10 "PID USER" |grep -v "PID USER"	|sed -n 5p |awk '{print $12}'`
	PER_PRO_NUM5_CPU_AVG=`echo "$PER_PRO_NUM5_CPU_USED / $PER_PRO_CPU_CNT" |bc`
	#printf "INSERT INTO PERFORMANCE_PROCESS(DATE_DAY,DATE_HMS,DATE_WEEK,CUB_PID,CUB_CPU_USED,CUB_MEM_USED,PER_PRO_NUM1_CMD,PER_PRO_NUM1_CPU_USED,PER_PRO_NUM1_MEM_USED,PER_PRO_NUM2_CMD,PER_PRO_NUM2_CPU_USED,PER_PRO_NUM2_MEM_USED,PER_PRO_NUM3_CMD,PER_PRO_NUM3_CPU_USED,PER_PRO_NUM3_MEM_USED,PER_PRO_NUM4_CMD,PER_PRO_NUM4_CPU_USED,PER_PRO_NUM4_MEM_USED,PER_PRO_NUM5_CMD,PER_PRO_NUM5_CPU_USED,PER_PRO_NUM5_MEM_USED)
	#VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK","$PER_PRO_PID","$PER_PRO_CPU_AVG","$PER_PRO_MEM_USED",\"$PER_PRO_NUM1_CMD\","$PER_PRO_NUM1_CPU_AVG","$PER_PRO_NUM1_MEM_USED",\"$PER_PRO_NUM2_CMD\","$PER_PRO_NUM2_CPU_AVG","$PER_PRO_NUM2_MEM_USED",\"$PER_PRO_NUM3_CMD\","$PER_PRO_NUM3_CPU_AVG","$PER_PRO_NUM3_MEM_USED",\"$PER_PRO_NUM4_CMD\","$PER_PRO_NUM4_CPU_AVG","$PER_PRO_NUM4_MEM_USED",\"$PER_PRO_NUM5_CMD\","$PER_PRO_NUM5_CPU_AVG","$PER_PRO_NUM5_MEM_USED");"`
	
	
	#PER_PRO_QUERY=`printf "INSERT INTO PERFORMANCE_PROCESS(DATE_DAY,DATE_HMS,DATE_WEEK,CUB_PID,CUB_CPU_USED,CUB_MEM_USED) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK","$PER_PRO_PID","$PER_PRO_CPU_AVG","$PER_PRO_MEM_USED");"`
	PER_PRO_QUERY=`printf "INSERT INTO PERFORMANCE_PROCESS(DATE_DAY,DATE_HMS,DATE_WEEK,CUB_PID,CUB_CPU_USED,CUB_MEM_USED,PER_PRO_NUM1_CMD,PER_PRO_NUM1_CPU_USED,PER_PRO_NUM1_MEM_USED,PER_PRO_NUM2_CMD,PER_PRO_NUM2_CPU_USED,PER_PRO_NUM2_MEM_USED,PER_PRO_NUM3_CMD,PER_PRO_NUM3_CPU_USED,PER_PRO_NUM3_MEM_USED,PER_PRO_NUM4_CMD,PER_PRO_NUM4_CPU_USED,PER_PRO_NUM4_MEM_USED,PER_PRO_NUM5_CMD,PER_PRO_NUM5_CPU_USED,PER_PRO_NUM5_MEM_USED) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK","$PER_PRO_PID","$PER_PRO_CPU_AVG","$PER_PRO_MEM_USED",\"$PER_PRO_NUM1_CMD\","$PER_PRO_NUM1_CPU_AVG","$PER_PRO_NUM1_MEM_USED",\"$PER_PRO_NUM2_CMD\","$PER_PRO_NUM2_CPU_AVG","$PER_PRO_NUM2_MEM_USED",\"$PER_PRO_NUM3_CMD\","$PER_PRO_NUM3_CPU_AVG","$PER_PRO_NUM3_MEM_USED",\"$PER_PRO_NUM4_CMD\","$PER_PRO_NUM4_CPU_AVG","$PER_PRO_NUM4_MEM_USED",\"$PER_PRO_NUM5_CMD\","$PER_PRO_NUM5_CPU_AVG","$PER_PRO_NUM5_MEM_USED");"`
	
	$UTIL_LOGDB  $LOGDB_PATH "$PER_PRO_QUERY"
	
	
	#pro_cub_server|pro_num1|pro_num2|pro_num3|pro_num4|pro_num5
}

function fn_performance_volume_9(){
	
	UTIL_CUB_SPACEDB=`cubrid spacedb --size-unit=g -s $DB_NAME@localhost`
	# VOLUME TYPE  = PER_VOL_9_DB_*_SIZE[0]
	# VOLUME TOTAL = PER_VOL_9_DB_*_SIZE[1]
	# VOLUME USED  = PER_VOL_9_DB_*_SIZE[2]
	# VOLUME FREE  = PER_VOL_9_DB_*_SIZE[3]
	PER_VOL_9_DB_DATA_SIZE=(`echo "$UTIL_CUB_SPACEDB" |grep "DATA" |sed 's/G//g'`)
	PER_VOL_9_DB_INDEX_SIZE=(`echo "$UTIL_CUB_SPACEDB" |grep "INDEX" |sed 's/G//g'`)
	PER_VOL_9_DB_GENERIC_SIZE=(`echo "$UTIL_CUB_SPACEDB" |grep "GENERIC" |sed 's/G//g'`)
	PER_VOL_9_DB_TEMP_SIZE=(`echo "$UTIL_CUB_SPACEDB" |grep -v "TEMP TEMP" |grep "TEMP" |sed 's/ G //g'`)
	PER_VOL_9_DB_TEMPTEMP_SIZE=(`echo "$UTIL_CUB_SPACEDB" |grep "TEMP TEMP" |sed 's/ G //g'|sed 's/TEMP TEMP/TEMP_TEMP/g'`)
	
	PER_VOL_9_TEMP_TOT_RESULT=`echo "$TEMP_TOT + $TEMP_TEMP_TOT"|bc`
	PER_VOL_9_TEMP_USED_RESULT=`echo "$TEMP_USED + $TEMP_TEMP_USED"|bc`
	PER_VOL_9_TEMP_FREE_RESULT=`echo "$TEMP_FREE + $TEMP_TEMP_FREE"|bc`

	PER_VOL_9_VOL_DATA_QUERY=`printf "INSERT INTO PERFORMANCE_VOLUME(DATE_DAY,DATE_HMS,DATE_WEEK,VOL_TYPE,TOT_SIZE,USED_SIZE,FREE_SIZE) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK",\"${PER_VOL_9_DB_DATA_SIZE[0]}\","${PER_VOL_9_DB_DATA_SIZE[1]}","${PER_VOL_9_DB_DATA_SIZE[2]}","${PER_VOL_9_DB_DATA_SIZE[3]}");"`
	
	PER_VOL_9_VOL_INDEX_QUERY=`printf "INSERT INTO PERFORMANCE_VOLUME(DATE_DAY,DATE_HMS,DATE_WEEK,VOL_TYPE,TOT_SIZE,USED_SIZE,FREE_SIZE) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK",\"${PER_VOL_9_DB_INDEX_SIZE[0]}\","${PER_VOL_9_DB_INDEX_SIZE[1]}","${PER_VOL_9_DB_INDEX_SIZE[2]}","${PER_VOL_9_DB_INDEX_SIZE[3]}");"`
		
	PER_VOL_9_VOL_GENERIC_QUERY=`printf "INSERT INTO PERFORMANCE_VOLUME(DATE_DAY,DATE_HMS,DATE_WEEK,VOL_TYPE,TOT_SIZE,USED_SIZE,FREE_SIZE) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK",\"${PER_VOL_9_DB_GENERIC_SIZE[0]}\","${PER_VOL_9_DB_GENERIC_SIZE[1]}","${PER_VOL_9_DB_GENERIC_SIZE[2]}","${PER_VOL_9_DB_GENERIC_SIZE[3]}");"`
		
	PER_VOL_9_VOL_TEMP_QUERY=`printf "INSERT INTO PERFORMANCE_VOLUME(DATE_DAY,DATE_HMS,DATE_WEEK,VOL_TYPE,TOT_SIZE,USED_SIZE,FREE_SIZE) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK",\"${PER_VOL_9_DB_TEMP_SIZE[0]}\","${PER_VOL_9_DB_TEMP_SIZE[1]}","${PER_VOL_9_DB_TEMP_SIZE[2]}","${PER_VOL_9_DB_TEMP_SIZE[3]}");"`
		
	PER_VOL_9_VOL_TEMPTEMP_QUERY=`printf "INSERT INTO PERFORMANCE_VOLUME(DATE_DAY,DATE_HMS,DATE_WEEK,VOL_TYPE,TOT_SIZE,USED_SIZE,FREE_SIZE) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK",\"${PER_VOL_9_DB_TEMPTEMP_SIZE[0]}\","${PER_VOL_9_DB_TEMPTEMP_SIZE[1]}","${PER_VOL_9_DB_TEMPTEMP_SIZE[2]}","${PER_VOL_9_DB_TEMPTEMP_SIZE[3]}");"`
	

	$UTIL_LOGDB  $LOGDB_PATH "$PER_VOL_9_VOL_DATA_QUERY"
	$UTIL_LOGDB  $LOGDB_PATH "$PER_VOL_9_VOL_INDEX_QUERY"
	$UTIL_LOGDB  $LOGDB_PATH "$PER_VOL_9_VOL_GENERIC_QUERY"	
	$UTIL_LOGDB  $LOGDB_PATH "$PER_VOL_9_VOL_TEMP_QUERY"
	$UTIL_LOGDB  $LOGDB_PATH "$PER_VOL_9_VOL_TEMPTEMP_QUERY"
}



function fn_performance_volume_10(){
	UTIL_CUB_SPACEDB=`cubrid spacedb --size-unit=g -s $DB_NAME@localhost`
	# VOLUME TYPE  = PER_VOL_9_DB_*_SIZE[0]
	# VOLUME TOTAL = PER_VOL_9_DB_*_SIZE[1]
	# VOLUME USED  = PER_VOL_9_DB_*_SIZE[2]
	# VOLUME FREE  = PER_VOL_9_DB_*_SIZE[3]
	PER_VOL_10_DB_GENERIC_SIZE=(`echo "$UTIL_CUB_SPACEDB" |grep -w "PERMANENT DATA" |sed 's/ G//g' |awk '{print "GENERIC" " " $7 " " $5 " " $6}'`)
	PER_VOL_10_DB_TEMP_SIZE=(`echo "$UTIL_CUB_SPACEDB" |grep "PERMANENT" |grep -w "TEMPORARY DATA" |sed 's/ G//g'| awk '{print "TEMP" " " $7 " " $5 " " $6}'`)
	PER_VOL_10_DB_TEMPTEMP_SIZE=(`echo "$UTIL_CUB_SPACEDB" |grep -v "PERMANENT" |grep -w "TEMPORARY DATA" |sed 's/ G//g' |awk '{print "TEMPTEMP" " " $7 " " $5 " " $6}'`)
	
	PER_VOL_10_VOL_GENERIC_QUERY=`printf "INSERT INTO PERFORMANCE_VOLUME(DATE_DAY,DATE_HMS,DATE_WEEK,VOL_TYPE,TOT_SIZE,USED_SIZE,FREE_SIZE) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK",\"${PER_VOL_10_DB_GENERIC_SIZE[0]}\","${PER_VOL_10_DB_GENERIC_SIZE[1]}","${PER_VOL_10_DB_GENERIC_SIZE[2]}","${PER_VOL_10_DB_GENERIC_SIZE[3]}");"`
	
	PER_VOL_10_VOL_TEMP_QUERY=`printf "INSERT INTO PERFORMANCE_VOLUME(DATE_DAY,DATE_HMS,DATE_WEEK,VOL_TYPE,TOT_SIZE,USED_SIZE,FREE_SIZE) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK",\"${PER_VOL_10_DB_TEMP_SIZE[0]}\","${PER_VOL_10_DB_TEMP_SIZE[1]}","${PER_VOL_10_DB_TEMP_SIZE[2]}","${PER_VOL_10_DB_TEMP_SIZE[3]}");"`
	
	PER_VOL_10_VOL_TEMPTEMP_QUERY=`printf "INSERT INTO PERFORMANCE_VOLUME(DATE_DAY,DATE_HMS,DATE_WEEK,VOL_TYPE,TOT_SIZE,USED_SIZE,FREE_SIZE) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\","$UTIL_CURRENT_WEEK",\"${PER_VOL_10_DB_TEMPTEMP_SIZE[0]}\","${PER_VOL_10_DB_TEMPTEMP_SIZE[1]}","${PER_VOL_10_DB_TEMPTEMP_SIZE[2]}","${PER_VOL_10_DB_TEMPTEMP_SIZE[3]}");"`

	$UTIL_LOGDB  $LOGDB_PATH "$PER_VOL_10_VOL_GENERIC_QUERY"	
	$UTIL_LOGDB  $LOGDB_PATH "$PER_VOL_10_VOL_TEMP_QUERY"
	$UTIL_LOGDB  $LOGDB_PATH "$PER_VOL_10_VOL_TEMPTEMP_QUERY"
}


function fn_performance_disk_9(){
		DB_MODE_CHECK_1=`$UTIL_CUB_SERVER_STATUS |grep -w "$DB_NAME"`

	if [ $DB_MODE_CHECK_1 -z ]; then
		2>/dev/null
	else
		DB_MODE_CHECK_2=`echo $DB_MODE_CHECK_1 |grep "HA"`
		
			if [ $DB_MODE_CHECK_2 -z ]; then
				# 싱글
				DB_MODE_CHECK="SINGLE"
				DB_MODE="SINGLE"
			else
				# HA
				DB_MODE_CHECK="HA"
				DB_MODE="HA"
			fi
	fi

################################################
# 파티션 영역 대비 엔진 영역 데이터 합계 ($CUBRID/databases 경로 제외)
################################################
	ENGINE_FILE_LIST=(`ls $CUBRID |grep -vw "databases"`)
	ENGINE_FILE_SIZE=0
	for ENGINE_FILE_NM in ${ENGINE_FILE_LIST[@]};	
		do
			ENGINE_FILE_SIZE_CHECK=`du -sk $CUBRID/$ENGINE_FILE_NM |awk '{print $1}'`
			ENGINE_FILE_SIZE=`echo "$ENGINE_FILE_SIZE + $ENGINE_FILE_SIZE_CHECK" |bc`
		done

	# 시작 값이 KB > 결과 MB
	ENGINE_USED_MB=`echo "$ENGINE_FILE_SIZE / 1024"|bc`
	ENGINE_PATH=`df -BM $CUBRID |grep -vw "Use" |grep "%" |awk '{print $NF}'`
	ENGINE_PATH_SIZE=`df -BM $CUBRID |grep -vw "Use" |grep "%" |awk '{print $(NF-4)}'|sed 's/M//g'`
	ENGINE_CALC=`echo "$ENGINE_USED_MB * 100 / $ENGINE_PATH_SIZE"|bc`

	# 엔진 영역 INSERT 질의 수행	
	ENGINE_SIZE_QUERY=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"ENGINE\",\"$ENGINE_PATH\","$ENGINE_PATH_SIZE","$ENGINE_USED_MB",\"$ENGINE_CALC%%\");"`
	$UTIL_LOGDB $LOGDB_PATH "$ENGINE_SIZE_QUERY"


################################################
## 파티션 영역 대비 데이터 영역 볼륨 사이즈 계산
## DATA, INDEX, TEMP, TEMP_TEMP
################################################
	DB_VOL_SIZE_1=0
	DB_VOL_SIZE_2=0
	DB_VOL_PATH=`cat $CUBRID/databases/databases.txt  |grep -v "#db-name" |grep -w "$DB_NAME" |awk '{print $2}'`
	DB_VOL_FILE_LIST=(`cat $DB_VOL_PATH"/"$DB_NAME"_vinf" |grep -v "\-[0-9]" |awk '{print $2}'`)

	for DB_VOL_FILE_CHECK in ${DB_VOL_FILE_LIST[@]}
		do
			DB_VOL_FILE_CHECK_PATH=`dirname $DB_VOL_FILE_CHECK`
			DB_VOL_FILE_CHECK_SIZE=`lsof -u $DB_ENGINE_USER |grep cub_serve |grep "$DB_NAME"|grep -w "$DB_VOL_FILE_CHECK"|awk '{print $7}'`
						
			if [ $DB_VOL_PATH = $DB_VOL_FILE_CHECK_PATH ]; then
				DB_VOL_SIZE_1=`echo "$DB_VOL_SIZE_1 + $DB_VOL_FILE_CHECK_SIZE" |bc`
				DB_VOL_PATH_1=`echo $DB_VOL_PATH`
			else
				DB_VOL_SIZE_2=`echo "$DB_VOL_SIZE_2 + $DB_VOL_FILE_CHECK_SIZE" |bc`
				DB_VOL_PATH_2=`echo $DB_VOL_FILE_CHECK_PATH`				
			fi
		done
		
	# TEMP TEMP 사이즈 추가	
	DB_TEMP_FILE_LIST=(`lsof -u $DB_ENGINE_USER |grep cub_serve |grep "$DB_NAME" |grep "$DB_NAME"_t[0-9] |awk '{print $7}'`)
	
	for DB_TEMP_FILE_CHECK in ${DB_TEMP_FILE_LIST[@]}
		do 
			DB_VOL_SIZE_1=`echo "$DB_VOL_SIZE_1 + $DB_TEMP_FILE_CHECK" |bc`
		done
	
	# BYTE 시작
	VOL_USED_MB_1=`echo "$DB_VOL_SIZE_1 / 1024 / 1024"|bc`
	VOL_PATH_1=`df -BM $DB_VOL_PATH_1 |grep -vw "Use" |grep "%" |awk '{print $NF}'`
	VOL_PATH_SIZE_1=`df -BM $DB_VOL_PATH_1 |grep -vw "Use" |grep "%" |awk '{print $(NF-4)}'|sed 's/M//g'`
	VOL_CALC_1=`echo "$VOL_USED_MB_1 * 100 / $VOL_PATH_SIZE_1"|bc`
	VOL_SIZE_QUERY_1=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"VOLUME_1\",\"$VOL_PATH_1\","$VOL_PATH_SIZE_1","$VOL_USED_MB_1",\"$VOL_CALC_1%%\");"`
	
	# VOLUME_1 경로 INSERT 수행
	$UTIL_LOGDB $LOGDB_PATH "$VOL_SIZE_QUERY_1"
	
	if [ $DB_VOL_PATH_2 -z ]; then
		2>/dev/null
	else
		VOL_USED_MB_2=`echo "$DB_VOL_SIZE_2 / 1024 / 1024"|bc`
		VOL_PATH_2=`df -BM $DB_VOL_PATH_2 |grep -vw "Use" |grep "%" |awk '{print $NF}'`
		VOL_PATH_SIZE_2=`df -BM $DB_VOL_PATH_2 |grep -vw "Use" |grep "%" |awk '{print $(NF-4)}'|sed 's/M//g'`
		VOL_CALC_2=`echo "$VOL_USED_MB_2 * 100 / $VOL_PATH_SIZE_1"|bc`
		
		VOL_SIZE_QUERY_2=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"VOLUME_2\",\"$VOL_PATH_2\","$VOL_PATH_SIZE_2","$VOL_USED_MB_2",\"$VOL_CALC_2%%\");"`
		
		# VOLUME_2 경로 INSERT 수행
		$UTIL_LOGDB $LOGDB_PATH "$VOL_SIZE_QUERY_2"
	fi
	
################################################
## 파티션 영역 대비 LOB 파일 사이즈 계산
################################################
	LOB_FILE_PATH=`cat $CUBRID/databases/databases.txt  |grep -w "$DB_NAME" |awk '{print $5}'|sed 's/file://g'`
	LOB_FILE_SIZE=`du -sk $LOB_FILE_PATH |awk '{print $1}'`

	# 시작 KB > 결과 MB
	LOB_USED_MB=`echo "$LOB_FILE_SIZE / 1024 " |bc`
	LOB_PATH=`df -BM $LOB_FILE_PATH |grep -vw "Used" |grep "%" |awk '{print $NF}'`
	LOB_PATH_SIZE=`df -BM $LOB_PATH |grep -vw "Used" |grep "%" |awk '{print $(NF-4)}' |sed 's/M//g'`
	LOB_CALC=`echo "$LOB_USED_MB * 100 / $LOB_PATH_SIZE" |bc`

	##LOB INSERT 수행	
	LOB_SIZE_QUERY=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"LOB\",\"$LOB_PATH\","$LOB_PATH_SIZE","$LOB_USED_MB",\"$LOB_CALC%%\");"`
	$UTIL_LOGDB $LOGDB_PATH "$LOB_SIZE_QUERY"

################################################
# 파티션 영역 대비 액티브 로그 및 아카이브 로그 파일 사이즈 계산
################################################
 LOG_FILE_LIST=(`lsof -u $DB_ENGINE_USER |grep cub_serve |grep -w $DB_NAME |grep -E "lgat|lgar" |awk '{print $7}'`)
 LOG_FILE_PATH=`lsof -u $DB_ENGINE_USER |grep cub_serve |grep -w $DB_NAME |grep -E "lgat|lgar"|head -n 1 |awk '{print $9}'`
 LOG_FILE_SIZE=0
 
	for LOG_FILE_NM in ${LOG_FILE_LIST[@]};
		do
			LOG_FILE_SIZE=`echo "$LOG_FILE_SIZE + $LOG_FILE_NM" |bc`
		done
	
	# BYTE 시작	> 결과 MB
	LOG_USED_MB=`echo "$LOG_FILE_SIZE / 1024 / 1024"|bc`
	LOG_PATH=`df -BM $LOG_FILE_PATH |grep -vw "Used" |grep "%" |awk '{print $NF}'`
	LOG_PATH_SIZE=`df -BM $LOG_PATH |grep -vw "Used" |grep "%" |awk '{print $(NF-4)}' |sed 's/M//g'`
	LOG_CALC=`echo "$LOG_USED_MB * 100 / $LOG_PATH_SIZE" |bc`

	# 액티브 로그 및 아카이브 로그 INSERT 수행
	LOG_SIZE_QUERY=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"LOG\",\"$LOG_PATH\","$LOG_PATH_SIZE","$LOG_USED_MB",\"$LOG_CALC%%\");"`
	
	$UTIL_LOGDB $LOGDB_PATH "$LOG_SIZE_QUERY"
	

################################################
# 파티션 영역 대비 COPYLOG 계산 (HA만 해당)
################################################
	if [ $DB_MODE_CHECK == "SINGLE" ]; then
		2>/dev/null
	elif [ $DB_MODE_CHECK == "HA" ]; then
		
		COPYLOG_FILE_PATH=`cubrid paramdump $DB_NAME@localhost |grep "ha_copy_log_base=" |sed 's/ha_copy_log_base=//g' |sed 's/""//g'`
		
		if [ $COPYLOG_FILE_PATH -z ]; then
			HOST_NAME=`hostname`
			COPYLOG_HOST=`cubrid hb status |grep Node |grep -vE "HA-Node|$HOST_NAME"|awk '{print $2}'`
			COPYLOG_SIZE=`du -sk $CUBRID/databases/"$DB_NAME"_$COPYLOG_HOST |awk '{print $1}'`
			COPYLOG_FILE_PATH=`echo $CUBRID/databases/"$DB_NAME"_$COPYLOG_HOST`
		else
			COPYLOG_SIZE=`du -sk $COPYLOG_FILE_PATH |awk '{print $1}'`
			COPYLOG_FILE_PATH=`echo $COPYLOG_FILE_PATH`
		fi
		
		# 시작 KB  > 결과 MB
		COPYLOG_USED_MB=`echo "$COPYLOG_SIZE / 1024" |bc`
		COPYLOG_PATH=`df -BM $COPYLOG_FILE_PATH |grep -vw "Used" |grep "%" |awk '{print $NF}'`
		COPYLOG_PATH_SIZE=`df -BM $COPYLOG_FILE_PATH |grep -vw "Used" |grep "%" |awk '{print $(NF-4)}' |sed 's/M//g'`
		COPYLOG_CALC=`echo "$COPYLOG_USED_MB * 100 / $COPYLOG_PATH_SIZE" |bc`
		
		# COPYLOG INSERT 수행
		COPYLOG_SIZE_QUERY=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"COPYLOG\",\"$COPYLOG_PATH\","$COPYLOG_PATH_SIZE","$COPYLOG_USED_MB",\"$COPYLOG_CALC%%\");"`
		$UTIL_LOGDB $LOGDB_PATH "$COPYLOG_SIZE_QUERY"
	fi	
}

function fn_performance_disk_10(){
	DB_MODE_CHECK_1=`cubrid server status |grep -w "$DB_NAME"`

	if [ $DB_MODE_CHECK_1 -z ]; then
		2>/dev/null
	else
		DB_MODE_CHECK_2=`echo $DB_MODE_CHECK_1 |grep "HA"`
		
			if [ $DB_MODE_CHECK_2 -z ]; then
				# 싱글
				DB_MODE_CHECK="SINGLE"
				DB_MODE="SINGLE"
			else
				# HA
				DB_MODE_CHECK="HA"
				DB_MODE="HA"
			fi
	fi

################################################
# 파티션 영역 대비 엔진 영역 데이터 합계 ($CUBRID/databases 경로 제외)
################################################
	ENGINE_FILE_LIST=(`ls $CUBRID |grep -v "databases"`)
	ENGINE_FILE_SIZE=0
	for ENGINE_FILE_NM in ${ENGINE_FILE_LIST[@]};	
		do
			ENGINE_FILE_SIZE_CHECK=`du -sk $CUBRID/$ENGINE_FILE_NM |awk '{print $1}'`
			ENGINE_FILE_SIZE=`echo "$ENGINE_FILE_SIZE + $ENGINE_FILE_SIZE_CHECK" |bc`
		done
	
	
	# 시작 값이 KB > 결과 MB
	ENGINE_USED_MB=`echo "$ENGINE_FILE_SIZE / 1024"|bc`
	ENGINE_PATH=`df -BM $CUBRID |grep -vw "Use" |grep "%" |awk '{print $NF}'`
	ENGINE_PATH_SIZE=`df -BM $CUBRID |grep -vw "Use" |grep "%" |awk '{print $(NF-4)}'|sed 's/M//g'`
	ENGINE_CALC=`echo "$ENGINE_USED_MB * 100 / $ENGINE_PATH_SIZE"|bc`
		
	# 엔진 영역 INSERT 수행
	ENGINE_SIZE_QUERY=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"ENGINE\",\"$ENGINE_PATH\","$ENGINE_PATH_SIZE","$ENGINE_USED_MB",\"$ENGINE_CALC%%\");"`
	$UTIL_LOGDB $LOGDB_PATH "$ENGINE_SIZE_QUERY"
	
	
################################################	
## 파티션 영역 대비 데이터 영역 볼륨 사이즈 계산
# PERMANENT, TEMP, TEMP_TEMP
################################################
	DB_VOL_SIZE_1=0
	DB_VOL_SIZE_2=0
	DB_VOL_PATH=`cat $CUBRID/databases/databases.txt  |grep -v "#db-name" |grep -w "$DB_NAME" |awk '{print $2}'`
	DB_VOL_FILE_LIST=(`cat $DB_VOL_PATH"/"$DB_NAME"_vinf" |grep -v "\-[0-9]" |awk '{print $2}'`)

	for DB_VOL_FILE_CHECK in ${DB_VOL_FILE_LIST[@]}
		do
			DB_VOL_FILE_CHECK_PATH=`dirname $DB_VOL_FILE_CHECK`
			DB_VOL_FILE_CHECK_SIZE=`lsof -u $DB_ENGINE_USER |grep cub_serve |grep "$DB_NAME"|grep -w "$DB_VOL_FILE_CHECK"|awk '{print $7}'`
						
			if [ $DB_VOL_PATH = $DB_VOL_FILE_CHECK_PATH ]; then
				DB_VOL_SIZE_1=`echo "$DB_VOL_SIZE_1 + $DB_VOL_FILE_CHECK_SIZE" |bc`
				DB_VOL_PATH_1=`echo $DB_VOL_PATH`
			else
				DB_VOL_SIZE_2=`echo "$DB_VOL_SIZE_2 + $DB_VOL_FILE_CHECK_SIZE" |bc`
				DB_VOL_PATH_2=`echo $DB_VOL_FILE_CHECK_PATH`				
			fi
		done

	# TEMP TEMP 사이즈 추가
	DB_TEMP_FILE_LIST=(`lsof -u $DB_ENGINE_USER |grep cub_serve |grep "$DB_NAME" |grep "$DB_NAME"_t[0-9] |awk '{print $7}'`)
	
	for DB_TEMP_FILE_CHECK in ${DB_TEMP_FILE_LIST[@]}
		do 
			DB_VOL_SIZE_1=`echo "$DB_VOL_SIZE_1 + $DB_TEMP_FILE_CHECK" |bc`
		done

	# BYTE 시작 > MB 계산
	VOL_USED_MB_1=`echo "$DB_VOL_SIZE_1 / 1024 / 1024"|bc`
	VOL_PATH_1=`df -BM $DB_VOL_PATH_1 |grep -vw "Use" |grep "%" |awk '{print $NF}'`
	VOL_PATH_SIZE_1=`df -BM $DB_VOL_PATH_1 |grep -vw "Use" |grep "%" |awk '{print $(NF-4)}'|sed 's/M//g'`
	VOL_CALC_1=`echo "$VOL_USED_MB_1 * 100 / $VOL_PATH_SIZE_1"|bc`
	
	# VOLUME_1 경로 INSERT 수행
	VOL_SIZE_QUERY_1=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"VOLUME_1\",\"$VOL_PATH_1\","$VOL_PATH_SIZE_1","$VOL_USED_MB_1",\"$VOL_CALC_1%%\");"`
	$UTIL_LOGDB $LOGDB_PATH "$VOL_SIZE_QUERY_1"
	
	if [ $DB_VOL_PATH_2 -z ]; then
		2>/dev/null
	else
		# BYTE 시작 > MB 계산
		VOL_USED_MB_2=`echo "$DB_VOL_SIZE_2 / 1024 / 1024"|bc`
		VOL_PATH_2=`df -BM $DB_VOL_PATH_2 |grep -vw "Use" |grep "%" |awk '{print $NF}'`
		VOL_PATH_SIZE_2=`df -BM $DB_VOL_PATH_2 |grep -vw "Use" |grep "%" |awk '{print $(NF-4)}'|sed 's/M//g'`
		VOL_CALC_2=`echo "$VOL_USED_MB_2 * 100 / $VOL_PATH_SIZE_1"|bc`
		
		# VOLUME_2 경로 INSERT 수행
		VOL_SIZE_QUERY_2=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"VOLUME_2\",\"$VOL_PATH_2\","$VOL_PATH_SIZE_2","$VOL_USED_MB_2",\"$VOL_CALC_2%%\");"`
		$UTIL_LOGDB $LOGDB_PATH "$VOL_SIZE_QUERY_2"
	fi


################################################
# 파티션 영역 대비 LOB 파일 사이즈 계산
################################################
	LOB_FILE_PATH=`cat $CUBRID/databases/databases.txt  |grep -w "$DB_NAME" |awk '{print $5}'|sed 's/file://g'`
	LOB_FILE_SIZE=`du -sk $LOB_FILE_PATH |awk '{print $1}'`

	# 시작 KB > MB 계산
	LOB_USED_MB=`echo "$LOB_FILE_SIZE / 1024 " |bc`
	LOB_PATH=`df -BM $LOB_FILE_PATH |grep -vw "Used" |grep "%" |awk '{print $NF}'`
	LOB_PATH_SIZE=`df -BM $LOB_PATH |grep -vw "Used" |grep "%" |awk '{print $(NF-4)}' |sed 's/M//g'`
	LOB_CALC=`echo "$LOB_USED_MB * 100 / $LOB_PATH_SIZE" |bc`

	# LOB INSERT 수행
	LOB_SIZE_QUERY=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"LOB\",\"$LOB_PATH\","$LOB_PATH_SIZE","$LOB_USED_MB",\"$LOB_CALC%%\");"`
	$UTIL_LOGDB $LOGDB_PATH "$LOB_SIZE_QUERY"


################################################
# 파티션 영역 대비 액티브 로그 및 아카이브 로그 파일 사이즈 계산
################################################
 LOG_FILE_LIST=(`lsof -u $DB_ENGINE_USER |grep cub_serve |grep -w $DB_NAME |grep -E "lgat|lgar" |awk '{print $7}'`)
 LOG_FILE_PATH=`lsof -u $DB_ENGINE_USER |grep cub_serve |grep -w $DB_NAME |grep -E "lgat|lgar"|head -n 1 |awk '{print $9}'`
 LOG_FILE_SIZE=0
 
	for LOG_FILE_NM in ${LOG_FILE_LIST[@]};
		do
			LOG_FILE_SIZE=`echo "$LOG_FILE_SIZE + $LOG_FILE_NM" |bc`
		done
	
	
	# BYTE 시작	> MB 계산
	LOG_USED_MB=`echo "$LOG_FILE_SIZE / 1024 / 1024"|bc`
	LOG_PATH=`df -BM $LOG_FILE_PATH |grep -vw "Used" |grep "%" |awk '{print $NF}'`
	LOG_PATH_SIZE=`df -BM $LOG_PATH |grep -vw "Used" |grep "%" |awk '{print $(NF-4)}' |sed 's/M//g'`
	LOG_CALC=`echo "$LOG_USED_MB * 100 / $LOG_PATH_SIZE" |bc`
	
	# 액티브 로그 및 아카이브 로그 INSERT 수행			
	LOG_SIZE_QUERY=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"LOG\",\"$LOG_PATH\","$LOG_PATH_SIZE","$LOG_USED_MB",\"$LOG_CALC%%\");"`
	$UTIL_LOGDB $LOGDB_PATH "$LOG_SIZE_QUERY"


################################################
# 파티션 영역 대비 COPYLOG 계산 (HA만 해당)
################################################		
	if [ $DB_MODE_CHECK == "SINGLE" ]; then
		2>/dev/null
	elif [ $DB_MODE_CHECK == "HA" ]; then
		
		COPYLOG_FILE_PATH=`cubrid paramdump $DB_NAME@localhost |grep "ha_copy_log_base=" |sed 's/ha_copy_log_base=//g' |sed 's/""//g'`
		
		if [ $COPYLOG_FILE_PATH -z ]; then
			HOST_NAME=`hostname`
			COPYLOG_HOST=`cubrid hb status |grep Node |grep -vE "HA-Node|$HOST_NAME"|awk '{print $2}'`
			COPYLOG_SIZE=`du -sk $CUBRID/databases/"$DB_NAME"_$COPYLOG_HOST |awk '{print $1}'`
			COPYLOG_FILE_PATH=`echo $CUBRID/databases/"$DB_NAME"_$COPYLOG_HOST`
		else
			COPYLOG_SIZE=`du -sk $COPYLOG_FILE_PATH |awk '{print $1}'`
			COPYLOG_FILE_PATH=`echo $COPYLOG_FILE_PATH`
		fi
		
		COPYLOG_USED_MB=`echo "$COPYLOG_SIZE / 1024" |bc`
		COPYLOG_PATH=`df -BM $COPYLOG_FILE_PATH |grep -vw "Used" |grep "%" |awk '{print $NF}'`
		COPYLOG_PATH_SIZE=`df -BM $COPYLOG_FILE_PATH |grep -vw "Used" |grep "%" |awk '{print $(NF-4)}' |sed 's/M//g'`
			
		COPYLOG_CALC=`echo "$COPYLOG_USED_MB * 100 / $COPYLOG_PATH_SIZE" |bc`
		
		# COPY LOG 계산
		COPYLOG_SIZE_QUERY=`printf "INSERT INTO PERFORMANCE_DISK(DATE_DAY,DATE_HMS,DATE_WEEK,DB_MODE, DATA_TYPE, DATA_PATH, DISK_TOT_SIZE, DISK_USED_SIZE, DISK_DATA_CALC) VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\",\"$DB_MODE\",\"COPYLOG\",\"$COPYLOG_PATH\","$COPYLOG_PATH_SIZE","$COPYLOG_USED_MB",\"$COPYLOG_CALC%%\");"`
		$UTIL_LOGDB $LOGDB_PATH "$COPYLOG_SIZE_QUERY"
	fi	
	
}


####################################################################################################################
#### [START] Main Function

#function fn_main(){
	if [ $1 == "start" ]; then
			#fn_user_config_check_output
			fn_user_config_check		
			fn_cubrid_env
			fn_version_check
			fn_cubrid_process_check
			fn_logdb_tables_check
			INTERVAL_DAY=`echo "$INTERVAL_DAY - 1"|bc`

		while true
			do 
				fn_performance_server_broker
				
				NUM_TPS=$PER_SV_BRO_TPS
				NUM_QPS=$PER_SV_BRO_QPS
				NUM_SELECT=$PER_SV_BRO_SELECT
				NUM_INSERT=$PER_SV_BRO_INSERT
				NUM_UPDATE=$PER_SV_BRO_UPDATE
				NUM_DELETE=$PER_SV_BRO_DELETE
				NUM_OTHERS=$PER_SV_BRO_OTHERS
				NUM_LONGT=$PER_SV_BRO_LONGT
				NUM_LONGQ=$PER_SV_BRO_LONGQ
				NUM_ERRQ=$PER_SV_BRO_ERRQ
				NUM_CONNECT=$PER_SV_BRO_CONNECT
				NUM_REJECT=$PER_SV_BRO_REJECT
				NUM_BUSY=$PER_SV_BRO_BUSY
				
				fn_current_date
				
				# INTERVAL_SEC = fn_performance_server_resource_info TOP Utility Delay Time(sec)
				
				fn_performance_server_resource_info
				fn_performance_process
				fn_performance_server_broker
								
				PER_SV_BRO_TPS=`echo "$PER_SV_BRO_TPS - $NUM_TPS" |bc`
				PER_SV_BRO_QPS=`echo "$PER_SV_BRO_QPS - $NUM_QPS" |bc`
				PER_SV_BRO_SELECT=`echo "$PER_SV_BRO_SELECT - $NUM_SELECT" |bc`
				PER_SV_BRO_INSERT=`echo "$PER_SV_BRO_INSERT - $NUM_INSERT" |bc`
				PER_SV_BRO_UPDATE=`echo "$PER_SV_BRO_UPDATE - $NUM_UPDATE" |bc`
				PER_SV_BRO_DELETE=`echo "$PER_SV_BRO_DELETE - $NUM_DELETE" |bc`
				PER_SV_BRO_OTHERS=`echo "$PER_SV_BRO_OTHERS - $NUM_OTHERS" |bc`
				PER_SV_BRO_LONGT=`echo "$PER_SV_BRO_LONGT - $NUM_LONGT" |bc`
				PER_SV_BRO_LONGQ=`echo "$PER_SV_BRO_LONGQ - $NUM_LONGQ" |bc`
				PER_SV_BRO_ERRQ=`echo "$PER_SV_BRO_ERRQ - $NUM_ERRQ" |bc`
				PER_SV_BRO_CONNECT=`echo "$PER_SV_BRO_CONNECT - $NUM_CONNECT" |bc`
				PER_SV_BRO_REJECT=`echo "$PER_SV_BRO_REJECT - $NUM_REJECT" |bc`
				PER_SV_BRO_BUSY=`echo "$PER_SV_BRO_BUSY - $NUM_BUSY" |bc`
			
				PERFORMANCE_SERVER_QUERY=`printf "INSERT INTO PERFORMANCE_SERVER(DATE_DAY,DATE_HMS,DATE_WEEK,CPU_USED,CPU_LOAD,IO_WAIT,MEM_TOTAL,MEM_USED,MEM_FREE,MEM_CALC,MEM_SWAP_TOTAL,MEM_SWAP_USED,MEM_SWAP_FREE,MEM_SWAP_CALC,DB_BUFFER_HIT,DB_TEMP_USED\
				,BROKER_PID,BROKER_AS,BROKER_JQ,BROKER_TPS,BROKER_QPS,BROKER_SELECT,BROKER_INSERT,BROKER_UPDATE,BROKER_DELETE,BROKER_OTHERS,BROKER_LONGT,BROKER_LONGQ,BROKER_ERRQ,BROKER_CONNECT,BROKER_REJECT,BROKER_BUSY) \
				VALUES(\"$UTIL_CURRENT_DAY\",\"$UTIL_CURRENT_HMS\",\"$UTIL_CURRENT_WEEK\","$PER_SV_CPU_USED","$PER_SV_CPU_LOAD","$PER_SV_IO_WAIT","$PER_SV_MEM_TOTAL","$PER_SV_MEM_USED","$PER_SV_MEM_FREE","$PER_SV_MEM_CALC","$PER_SV_MEM_SWAP_TOTAL","$PER_SV_MEM_SWAP_USED","$PER_SV_MEM_SWAP_FREE","$PER_SV_MEM_SWAP_CALC","$PER_SV_BUFFER_HIT","$PER_SV_TEMP_USED_RESULT","$PER_SV_BRO_PID","$PER_SV_BRO_AS","$PER_SV_BRO_JQ","$PER_SV_BRO_TPS","$PER_SV_BRO_QPS","$PER_SV_BRO_SELECT","$PER_SV_BRO_INSERT","$PER_SV_BRO_UPDATE","$PER_SV_BRO_DELETE","$PER_SV_BRO_OTHERS","$PER_SV_BRO_LONGT","$PER_SV_BRO_LONGQ","$PER_SV_BRO_ERRQ","$PER_SV_BRO_CONNECT","$PER_SV_BRO_REJECT","$PER_SV_BRO_BUSY");"`
			
				PER_VOL_DAY_CHECK=`$UTIL_LOGDB $LOGDB_PATH "SELECT DATE_DAY FROM PERFORMANCE_VOLUME ORDER BY DATE_DAY DESC LIMIT 1"`
				PER_DISK_DAY_CHECK=`$UTIL_LOGDB $LOGDB_PATH "SELECT DATE_DAY FROM PERFORMANCE_DISK ORDER BY DATE_DAY DESC LIMIT 1"`
				
				PER_VOL_DAY_INTERVAL=`date +%Y-%m-%d -d "$PER_VOL_DAY_CHECK +$INTERVAL_DAY days"`
				PER_DISK_DAY_INTERVAL=`date +%Y-%m-%d -d "$PER_DISK_DAY_CHECK +$INTERVAL_DAY days"`
				
				
					if [ $CUBRID_VERSION = "9" ];then
						if [ $UTIL_CURRENT_DAY = $PER_VOL_DAY_CHECK ]; then
							2>/dev/null
						else
							fn_performance_volume_9
						fi
						
						if [ $UTIL_CURRENT_DAY = $PER_DISK_DAY_CHECK ]; then
							2>/dev/null
						else
							fn_performance_disk_9
						fi
					elif [ $CUBRID_VERSION = "10" ];then
						if [ $UTIL_CURRENT_DAY = $PER_VOL_DAY_CHECK ]; then
							2>/dev/null
						else
							fn_performance_volume_10
						fi
						
						if [ $UTIL_CURRENT_DAY = $PER_DISK_DAY_CHECK ]; then
							2>/dev/null
						else
							fn_performance_disk_10
						fi

					fi
			
				$UTIL_LOGDB $LOGDB_PATH "$PERFORMANCE_SERVER_QUERY"
		done
	
	elif [ $1 == "-v" ]; then
		echo "> PERFORMANCE Script Version : 2018.12.09 freeze up"
	elif [ $1 == "-h" ] || [ $1 != "-v" ] || [ $1 != "start" ] || [ $1 -z ]; then 
		echo "[CUBRID PERFORMANCE Scipt usage]"
		echo "> cub_performance.sh start : Running "
		echo "> cub_performance.sh -v    : Version"
		echo "> cub_performance.sh -h    : help"
		exit
	fi
}
#fn_main $1 2>/dev/null
#fn_main 2>/dev/null
#### [END] Main Function
