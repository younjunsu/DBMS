#!/bin/sh
### Background Monitoring Start ###
### nohup mon.sh >> mon.log & ###

TIME=$1
if [ "$1" = "" ]
then
         TIME=60 #시간간격(초)
fi

while :
do
date '+[%Y/%m/%d %H:%M:%S]'
#       clear
        echo "------ RTPC(Real Time Process Checker) ---------------------------------------"
#        echo " "
#        echo "USER     PID    PPID  PCPU    VSZ    RSS   PMEM COMMAND"
#        echo "USER         PID %CPU %MEM   SZ  RSS    TTY STAT     STIME  TIME COMMAND"
#        echo "-------- -----  ---- ----- ------ ------ ------ --------------------------------------------"
#Linux
#ps -e -o user,pid,ppid,pcpu,vsz,args | egrep -v "grep|ps|sh|COMMAND|sed" | sort -r -k 5 | head -n 15 |cut -c1-70
#echo "USER     PID    PPID  PCPU    VSZ  COMMAND"
#AIX
#ps aeuwg |grep -E "tibero" |grep "tbsvr" |grep -v -E "grep|ps|sh|sed" |sort -n -k 6 | head -n 15 |cut -c1-120
echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
ps aeuwg |grep -E "tibero" | grep -v "grep|ps|sh|COMMAND|sed" | sort -n -r -k 6 | head -n 50 |cut -c1-120

#Solaris
#        ps -e -o user,pid,ppid,pcpu,vsz,rss,pmem,args | egrep -v "grep|ps|sh|COMMAND|sed" | sort -n -r -k 6 | head -n 50 |cut -c1-70

        echo "-------- -----  ---- ----- ------ ------ ------ --------------------------------------------"
        echo " "
        echo "------ RTPC(Real Time Storage Checker) ---------------------------------------"
df -k
        echo " "
        echo "------ RTPC(Real Time VMSTAT Checker) ---------------------------------------"
vmstat 

        echo " "
        echo "------ RTPC(Real Time Session Checker) ---------------------------------------"


tbsql -s sys/tibero << EOF
SET FEEDBACK OFF
set linesize 132

select  '[' || TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') || ']' as "Current Time",
	sum(pga_used_mem) as "Working PGA" from v\$process where name='WTHR';

select * from v\$process where name='WTHR' and pga_used_mem <> 0;

exit;
EOF
        echo " "
        echo "------ INTERVAL =" $TIME "------------------------------------------------------------"
        sleep $TIME
done
