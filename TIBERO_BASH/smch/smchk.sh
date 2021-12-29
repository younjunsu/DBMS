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

### RUN CHECK


### Summary
function fn_sysmaster_summary(){
    echo "UP-Time"
    uptime -s |awk '{print "Server Time : "$1" "$2}'

    echo "TIBERO UP-Time"
    ps -eo lstart,pid,cmd |grep $DB_LIST_02|grep -vE "grep|cub_admin"| awk '{
    cmd="date -d\""$1 FS $2 FS $3 FS $4 FS $5"\" +\047%Y-%m-%d %H:%M:%S\047"; 
    cmd | getline d; close(cmd); $1=$2=$3=$4=$5=""; printf "%s\n",d$0 }' 2>/dev/null|awk '{print $1" "$2}'

    echo "JEUS UP-Time"

    
    echo "Hyper Loader UP-Time"
}

### JEUS Detail


### Hyperloader Detail


### Repository TIBERO Detail
tbsql sys/tibero @smchk.sql <<EOF
quit


EOF

### Control TIBERO Detail





  