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


    echo "######## 1. Started Time ########"
# SYSTEM
    echo "######## 1.1 System"
    echo "System -> "`uptime -s |awk '{print $1" "$2}'`
    echo
# SMDB
    SMDB_PID=(`ps -ef |grep -w tbsvr |grep -v grep |awk '{print $2}'`)
    SMDB_STARTTIME=`ps -eo lstart,pid,cmd |grep $SMDB_PID|grep -vE "grep|cub_admin"| awk '{
    cmd="date -d\""$1 FS $2 FS $3 FS $4 FS $5"\" +\047%Y-%m-%d %H:%M:%S\047"; 
    cmd | getline d; close(cmd); $1=$2=$3=$4=$5=""; printf "%s\n",d$0 }' 2>/dev/null |awk '{print $1" "$2}'`
    echo "######## 1.2 SMDB"
    echo "SMDB -> PID : "$SMDB_PID", Start-Time : "$SMDB_STARTTIME
    echo
#JEUS
    echo "######## 1.3 JEUS"
    jps |grep -v Jps |awk '{print "PID : "$1", CMD : "$2}'

#Hyper Loader
    echo "######## 1.4 HyperLoader"
    
## Process and listening port check
    echo ""######## 2. Port check ########"
    echo 
    echo "Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    "
    netstat -nlp |grep tcp 



tbsql sys/tibero @smchk.sql <<EOF
quit


EOF

### Control TIBERO Detail





  