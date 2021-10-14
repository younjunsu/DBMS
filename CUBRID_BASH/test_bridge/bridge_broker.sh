#!/bin/bash
## coding = utf8

# brk
global_config_brk_name=$1

# one
global_config_db_name=demodb

# s
global_config_interval=60


cubrid broker status -b "$global_config_brk_name"
cubrid broker status -f -b "$global_config_brk_name"

sleep 60

cubrid broker status -b "$global_config_brk_name"
cubrid broker status -f -b "$global_config_brk_name"



brk_stats_b=(`cat bridge.config |grep -A14 "BROKER STATUS" |grep -v "#"`)

brk_stats_tps=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "TPS"`
brk_stats_qps=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "QPS"`
brk_stats_jq=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "JQ"`
brk_stats_sel=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "SELECT"`
brk_stats_ins=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "INSERT"`
brk_stats_upd=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "UPDATE"`
brk_stats_del=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "DELETE"`
brk_stats_oth=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "OTHER"`
brk_stats_longt=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "LONG-T"`
brk_stats_longq=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "LONG-Q"`
brk_stats_errq=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "ERR-Q"`
brk_stats_uniqerrq=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "UNIQUE-ERR-Q"`
brk_stats_conn=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "CONNECT"`
brk_stats_rej=`printf "%s\n" "${brk_stats_b[@]}" |grep -w "REJECT"`


brk_stats_b_f=(`cat bridge.config |grep -A5 "BROKER CAS" |grep -v "#"`)

brk_stats_cas_t=`printf "%s\n" "${brk_stats_b_f[@]}" |grep "TRAN"`
brk_stats_cas_w=`printf "%s\n" "${brk_stats_b_f[@]}" |grep "WAIT"`
brk_stats_cas_b=`printf "%s\n" "${brk_stats_b_f[@]}" |grep "BUSY"`
brk_stats_cas_sw=`printf "%s\n" "${brk_stats_b_f[@]}" |grep "time(s)-W"`
brk_stats_cas_sb=`printf "%s\n" "${brk_stats_b_f[@]}" |grep "time(s)-B"`

#echo -n "TEST #01 : "
#for num in {1..60}
#do
#BROKER_STATUS=(`cubrid broker status -f -b query_editor |grep -vE "cubrid broker status|NAME                   PID|============"`)
#TPS=`echo ${BROKER_STATUS[@]} |awk '{print $16}'`
#QPS=`echo ${BROKER_STATUS[@]} |awk '{print $17}'`
#        echo -n `date` " - TPS - "
#        echo -ne "\e[43;1;31m"" $TPS ""\e[0m"
#        echo
#        echo -n `date` " - QPS - "
#        echo -ne "\e[43;1;31m"" $QPS ""\e[0m"
#        sleep 1
#        clear
#done
#echo
