#!/usr/bin/bash
#-------------------------------------------------------------------------------
# @File name      : smchk.sh
# @Contents       : 
# @Created by     : 
# @Created date   : 
# @Team           : 
# @Modifed History 
# ------------------------------------------------------------------------------
# xxxx.xx.xx xxxxx                 (Verxx)
# ------------------------------------------------------------------------------
## ENV CHECK
TB_HOME
TB_SID
JEUS_HOME
SYSMASTER_HOME
HL_HOME
PROOBJECT_HOME



## STEP 1
STEP=1
echo "######## $STEP. SYSTEM RESOURCE ########"
echo "######## $STEP.1 Memory ########"
free -g
echo
echo "######## $STEP.2 CPU ########"
SYSTEM_CPU=`cat /proc/cpuinfo |grep -i "physical id" |sort |uniq -c |awk '{print $1}' |wc -l`
SYSTEM_CORE=`cat /proc/cpuinfo |grep -i "physical id" |sort |uniq -c |awk '{sum +=$1} END {print sum}'`
echo "CPU = "$SYSTEM_CPU", CORE ="$SYSTEM_CORE
echo
echo
## STEP 2
STEP=2
    echo "######## $STEP. Started Time ########"
    printf "%-20s%-50s%-20s%-30s\n" "TYPE" "Prcess CMD" "PID" "START-TIME"
    echo "-------------------------------------------------------------------------------------------------------------"
# SYSTEMD
    SYSTEM_STARTTIME=`uptime -s`
    SYSTEM_CMD="systemd"
    printf "%-20s%-50s%-20s%-30s\n" "SYSTEM" "$SYSTEM_CMD" "1" "$SYSTEM_STARTTIME"
    
# SMDB
    SMDB_PID=`ps -ef |grep -w tbsvr |grep -v grep |awk '{print $2}'`
    SMDB_STARTTIME=`ps -eo lstart,pid,cmd |grep $SMDB_PID|grep -vE "grep|cub_admin"| awk '{
    cmd="date -d\""$1 FS $2 FS $3 FS $4 FS $5"\" +\047%Y-%m-%d %H:%M:%S\047"; 
    cmd | getline d; close(cmd); $1=$2=$3=$4=$5=""; printf "%s\n",d$0 }' 2>/dev/null |awk '{print $1" "$2}'`
    SMDB_CMD="TIBERO"
    printf "%-20s%-50s%-20s%-30s\n" "SMDB" "$SMDB_CMD" "$SMDB_PID" "$SMDB_STARTTIME"

#JEUS
    JEUS_PIDS=(`ps -ef|grep sysmaster |grep java |grep jeus |awk '{print $2}'`)
    for JEUS_PID in ${JEUS_PIDS[@]}
    do
        JEUS_STARTTIME=`ps -eo lstart,pid,cmd |grep $JEUS_PID|grep -vE "grep|cub_admin"| awk '{
        cmd="date -d\""$1 FS $2 FS $3 FS $4 FS $5"\" +\047%Y-%m-%d %H:%M:%S\047"; 
        cmd | getline d; close(cmd); $1=$2=$3=$4=$5=""; printf "%s\n",d$0 }' 2>/dev/null |awk '{print $1" "$2}'`
        JEUS_CMD=`jps |grep $JEUS_PID |awk '{print $2}'`

        printf "%-20s%-50s%-20s%-30s\n" "JEUS" "$JEUS_CMD" "$JEUS_PID" "$JEUS_STARTTIME"
    done

#HyperLoader
    HYPER_PIDS=(`ps -ef|grep hyper |grep -v grep |awk '{print $2}'`)
    for HYPER_PID in ${HYPER_PIDS[@]}
    do
        HYPER_STARTTIME=`ps -eo lstart,pid,cmd |grep $HYPER_PID|grep -vE "grep|cub_admin"| awk '{
        cmd="date -d\""$1 FS $2 FS $3 FS $4 FS $5"\" +\047%Y-%m-%d %H:%M:%S\047"; 
        cmd | getline d; close(cmd); $1=$2=$3=$4=$5=""; printf "%s\n",d$0 }' 2>/dev/null |awk '{print $1" "$2}'`
        HYPER_CMD="Loader"

        printf "%-20s%-50s%-20s%-30s\n" "HyperLoader" "$HYPER_CMD" "$HYPER_PID" "$HYPER_STARTTIME"
    done
    echo
    echo
## STEP 3
STEP=3
    echo "######## $STEP. Port check ########"
    echo "Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    "
    netstat -nlp |grep tcp 
    echo
    echo
## STEP 4
STEP=4
    echo "######## $STEP. Space usage ########"
    echo "######## $STEP.1 Total ########"
    df -h
    echo
    echo "######## $STEP.2 Size on by type ########"
    SYSMASTER_HOME_SIZE=(`df -h $SYSMASTER_HOME|grep -v Mounted`)
    TB_HOME_SIZE=(`df -h $TB_HOME|grep -v Mounted`)
    JEUS_HOME_SIZE=(`df -h $JEUS_HOME|grep -v Mounted`)
    HL_HOME_SIZE=(`df -h $HL_HOME|grep -v Mounted`)
    PROOBJECT_HOME_SIZE=(`df -h $PROOBJECT_HOME|grep -v Mounted`)
    printf "%-15s%-10s%-10s%-10s%-10s%-20s\n" "HOME TYPE" "Size" "Used" "Avail" "Use%" "Mounted on"
    printf "%-15s%-10s%-10s%-10s%-10s%-20s\n" "SYSMASTER" "${SYSMASTER_HOME_SIZE[1]}" "${SYSMASTER_HOME_SIZE[2]}" "${SYSMASTER_HOME_SIZE[3]}" "${SYSMASTER_HOME_SIZE[4]}" "${SYSMASTER_HOME_SIZE[5]}"
    printf "%-15s%-10s%-10s%-10s%-10s%-20s\n" "SMDB" "${TB_HOME_SIZE[1]}" "${TB_HOME_SIZE[2]}" "${TB_HOME_SIZE[3]}" "${TB_HOME_SIZE[4]}" "${TB_HOME_SIZE[5]}"
    printf "%-15s%-10s%-10s%-10s%-10s%-20s\n" "JEUS" "${JEUS_HOME_SIZE[1]}" "${JEUS_HOME_SIZE[2]}" "${JEUS_HOME_SIZE[3]}" "${JEUS_HOME_SIZE[4]}" "${JEUS_HOME_SIZE[5]}"
    printf "%-15s%-10s%-10s%-10s%-10s%-20s\n" "HyperLoader" "${HL_HOME_SIZE[1]}" "${HL_HOME_SIZE[2]}" "${HL_HOME_SIZE[3]}" "${HL_HOME_SIZE[4]}" "${HL_HOME_SIZE[5]}"
    printf "%-15s%-10s%-10s%-10s%-10s%-20s\n" "ProObject" "${PROOBJECT_HOME_SIZE[1]}" "${PROOBJECT_HOME_SIZE[2]}" "${PROOBJECT_HOME_SIZE[3]}" "${PROOBJECT_HOME_SIZE[4]}" "${PROOBJECT_HOME_SIZE[5]}"
    echo
    echo "######## $STEP.3 SMDB Talespace usage ########"
    tbsql sys/tibero  << EOF
     set linesize 500;
	set feedback off;
	col "Tablespace Name" format a20;
	col "Bytes(MB)"       format 999,999,999;
	col "MaxBytes(MB)"    format 999,999,999;
	col "Used(MB)"        format 999,999,999;
	col "Percent(%)"      format 9999999.99;
	col "Free(MB)"        format 999,999,999;
	col "Free_REAL(MB)"   format 999,999,999;

    SELECT TO_CHAR(sysdate, 'yyyy/mm/dd hh24:mi:ss') "Current Time",
           TABLESPACE_NAME  "Tablespace Name",
                   SUM("total MB")  "Bytes(MB)",
                   SUM("max MB")    "MaxBytes(MB)",
                   SUM("Used MB")   "Used(MB)",
                   round( (SUM("Used MB") / SUM("total MB") * 100 ),2 ) "Percent(%)",
                   SUM("Free MB")  "Free(MB)",
                   SUM("max MB")-SUM("Used MB") "Free_REAL(MB)",
                   round( (SUM("max MB")-SUM("Used MB")) / SUM("max MB") * 100, 2) "Free_REAL(%)"
            FROM   (Select D.TABLESPACE_NAME,
                           d.file_name "Datafile name",
                           DECODE(SUM(f.Bytes), null, ROUND(MAX(d.bytes)/1024/1024,2),
                                                      ROUND((MAX(d.bytes)/1024/1024) - (SUM(f.bytes)/1024/1024),2)) "Used MB",
                           DECODE(SUM(f.bytes), null, 0, ROUND(SUM(f.Bytes)/1024/1024,2)) "Free MB" ,
                           ROUND(MAX(d.bytes)/1024/1024,2) "total MB",
                           DECODE(ROUND(MAX(d.MAXBYTES)/1024/1024,2), 0, ROUND(MAX(d.bytes)/1024/1024,2),
                                                                         ROUND(MAX(d.MAXBYTES)/1024/1024,2)) "max MB"
                      From (SELECT * FROM DBA_FREE_SPACE WHERE BYTES/1024/1024 > 1) f , DBA_DATA_FILES d
                     Where f.tablespace_name(+) = d.tablespace_name
                       And f.file_id(+) = d.file_id
                     Group by D.TABLESPACE_NAME, d.file_name
                     Order by D.TABLESPACE_NAME
                   )
            GROUP BY TABLESPACE_NAME
            ORDER BY "Free_REAL(%)", "Tablespace Name"
    ;
    quit

EOF
    echo
    echo
## STEP 5
STEP=5
    echo "######## $STEP. CPU used TOP 10 ########"
    echo "USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
    ps -aux  |grep -v "%MEM"|sort -k 3 -r |head -n 10

## STEP 6
STEP=6
    echo "######## $STEP. LOG CHECK ########"
    cd $SYSMASTER_HOME
# SMDB
    printf "%-20s%-100s\n" "SMDB" "LOG FILE"
    echo "-----------------------------------"
    SMDB_LOGFILES=(`find tibero6/instance -mtime -30 -name '*.log' -o -name '*.out'`)
    for SMDB_LOGFILE in ${SMDB_LOGFILES[@]}
    do
        printf "%-20s%-100s\n" "SMDB" "$SMDB_LOGFILE"
    done
    echo
    echo
# JEUS
    printf "%-20s%-100s\n" "JEUS" "LOG FILE"
    echo "-----------------------------------"
    JEUS_LOGFILES=(`find jeus8 -mtime -30 -name '*.log' -o -name '*.out'`)
    for JEUS_LOGFILE in ${JEUS_LOGFILES[@]}
    do
        printf "%-20s%-100s\n" "JUES" "$JEUS_LOGFILE"
    done
    echo
    echo
# HyperLoader
    printf "%-20s%-100s\n" "HyperLoader" "LOG FILE"
    echo "-----------------------------------"
    HYPER_LOGFILES=(`find hyperLoader -mtime -30 -name '*.log' -o -name '*.out'`)
    for HYPER_LOGFILE in ${HYPER_LOGFILES[@]}
    do
        printf "%-20s%-100s\n" "HyperLoader" "$HYPER_LOGFILE"
    done
    echo
    echo
# ProObject
    printf "%-20s%-100s\n" "ProObject" "LOG FILE"
    echo "-----------------------------------"
    PROOB_LOGFILES=(`find proobject7 -mtime -30 -name '*.log' -o -name '*.out'`)
    for PROOB_LOGFILE in ${PROOB_LOGFILES[@]}
    do
        printf "%-20s%-100s\n" "ProObject" "$PROOB_LOGFILE"
    done
    echo
    echo

    
