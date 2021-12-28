#!/bin/sh
### Background Monitoring Start ###
### nohup ha_mon.sh >> ha_mon.log & ###

TIME=$1
if [ "$1" = "" ]
then
         TIME=10 #시간간격(초)
fi

while :
do
clear
date '+[%Y/%m/%d %H:%M:%S]'
echo ""
echo "[Disk Mount]"
df -gt /ora_* /tb_* |grep -v Filesystem |wc -l

echo ""
echo "[Tibero Process Count]"
ps -ef |grep tbsvr |grep -v grep |wc -l

echo ""
echo "[Tibero session]"
tbsql -s sys/tibero << EOF
set linesize 132
set feedback off
col username for a15

select username, prog_name, count(*) from v\$session
group by username, prog_name;

exit;
EOF
        sleep $TIME
done
