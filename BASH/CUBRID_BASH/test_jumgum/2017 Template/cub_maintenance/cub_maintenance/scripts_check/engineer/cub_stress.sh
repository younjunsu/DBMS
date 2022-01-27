
#-----------------------------------------
# Shell name   : Operate Monitor
# Created date : 2017.09.14
#-----------------------------------------

nodat_cub=`ls ~/cubrid.sh 2>/dev/null `
dat_cub=`ls ~/.cubrid.sh  2>/dev/null`


if [ $dat_cub -z ] 2>/dev/null; then
   if [ $nodat_cub -z ] 2>/dev/null; then
   echo "Need to check environment variables. "
   else
      . ~/cubrid.sh
   fi
else
   . ~/.cubrid.sh
fi


mkdir -p $CUBRID/tmp/cub_maintenance/stress_result/`date +"%Y%m%d"`

# function -------------------------------
Wait_Period() {
  __PREV__=${__NOW__}
  local __PERIOD__=$1
  __NOW__=`awk 'BEGIN { print systime() }'`
  if [ "${__PREV__}" = "" ] ; then
    __PREV__=${__NOW__}
  fi
  __MOD__=`expr ${__NOW__} % ${__PERIOD__} 2>/dev/null `
  sleep `expr ${__PERIOD__} - ${__MOD__} 2>/dev/null `
  __NOW__=`awk 'BEGIN { print systime() }'`
#  __DIFF__=`expr ${__NOW__} - ${__PREV__}`
#
#  return ${__DIFF__}
}

active_transaction(){
total_active=0
until [ "$i" == `expr $1 + 1 ` ]
do
pass=$3
DB_NAME=$2
echo "`date +"%Y/%m/%d %H:%M:%S"`"
if [ -z $pass ]
then
	pass=" "
else
	pass="-p $pass"
fi
current_active=`cubrid killtran $pass $DB_NAME@localhost | grep ACTIVE | wc -l`
echo " ACTIVE Count : $current_active "
echo " ACTIVE List"
echo " ==============================================================================================="
cubrid killtran $pass $DB_NAME@localhost | grep ACTIVE
echo " ==============================================================================================="
echo
total_active=`expr $total_active + $current_active 2>/dev/null `
i=`expr $i + 1 2>/dev/null `
#echo "`date +"%Y/%m/%d %H:%M:%S"`"
echo
echo
Wait_Period 5

done
average_active=`expr $total_active / $1 2>/dev/null `
echo " ==============================="
echo " Average ACTIVE Session : $average_active "
echo " ==============================="
}


broker_busy(){
total_busy=0
Bro_name=$2
until [ "$i" == `expr $1 + 1` ]
do
Bro_name=query_editor
echo "`date +"%Y/%m/%d %H:%M:%S"`"
current_busy=`cubrid broker status -f | grep $Bro_name | grep BUSY | wc -l`
echo " BUSY Count : $current_busy"
echo " BUSY List"
echo " ==============================================================================================="
cubrid broker status -f | grep $Bro_name | grep BUSY
echo " ==============================================================================================="
echo 
total_busy=`expr $total_busy + $current_busy 2>/dev/null `
i=`expr $i + 1 2>/dev/null `
#echo "`date +"%Y/%m/%d %H:%M:%S"`"
echo
echo
Wait_Period 5

done
average_busy=`expr $total_busy / $1 2>/dev/null `
echo " ==============================="
echo " Average Broker Busy : $average_busy"
echo " ==============================="

}

QPS_TPS(){
Bro_name=$2
total_tps=0
total_qps=0
until [ "$i" == `expr $1 + 1 ` ]
do
echo "`date +"%Y/%m/%d %H:%M:%S"`"
old_tps=`cubrid broker status -b | grep $Bro_name | awk '{print $7}' `
old_qps=`cubrid broker status -b | grep $Bro_name | awk '{print $8}' `
Wait_Period 5
current_tps=`cubrid broker status -b | grep $Bro_name | awk '{print $7}' `
current_qps=`cubrid broker status -b | grep $Bro_name | awk '{print $8}' `

result_tps=`expr $current_tps - $old_tps 2>/dev/null `
result_qps=`expr $current_qps - $old_qps 2>/dev/null `

total_tps=`expr $total_tps + $result_tps 2>/dev/null `
total_qps=`expr $total_qps + $result_qps 2>/dev/null `
echo
echo "========================="
echo " TPS Count    : $result_tps "
echo " QPS Count    : $result_qps "
echo "========================="
i=`expr $i + 1 2>/dev/null `
echo
echo
done
imsi=`expr 5 \* $1 2>/dev/null `
ever_tps=`expr $total_tps / $imsi 2>/dev/null `
ever_qps=`expr $total_qps / $imsi 2>/dev/null `
echo "========================="
echo " TPS Average    : $ever_tps "
echo " QPS Average    : $ever_qps "
echo "========================"
}

cpu_check(){
echo "`date +"%Y/%m/%d %H:%M:%S"`"
echo
sar 1 $1
}

log_top(){
Bro_name=$1
default_dir="log/broker/sql_log"
log_dir=`cat $CUBRID/conf/cubrid_broker.conf |grep -i -A15 $1 |grep LOG_DIR |grep -v '#'|grep -v 'error'|awk '{print $2}'|sed -s 's/=/ /g'`
if [ $log_dir == $default_dir ]
then
		cd $CUBRID/$default_dir
		tar -czvf $CUBRID/tmp/cub_maintenance/stress_result/`date +"%Y%m%d"`/"$Bro_name"_old_log.tar.gz * 1>/dev/null 
		rm $CUBRID/$default_dir/$Bro_name*
else
		cd $log_dir/
		tar -czvf $CUBRID/tmp/cub_maintenance/stress_result/`date +"%Y%m%d"`/"$Bro_name"_old_log.tar.gz * 1>/dev/null
		rm $log_dir/$Bro_name*
fi

}



i=1
if [ -z $1 ]
then
	echo " Input Time "
else
imsi=`expr $1 / 5 2>/dev/null `
############# QPS ####################
for Bro_name in broker1 query_editor
do
QPS_TPS $imsi $Bro_name  >> $CUBRID/tmp/cub_maintenance/stress_result/`date +"%Y%m%d"`/"$Bro_name"_qps.txt &
done
#####################################

############# BUSY ##################
for Bro_name in broker1 query_editor
do
broker_busy $imsi $Bro_name >> $CUBRID/tmp/cub_maintenance/stress_result/`date +"%Y%m%d"`/"$Bro_name"_broker.txt &
done
#####################################

############ Tran ###################
for DB_NAME in demodb
do
echo -e " Input yout dba password ON $DB_NAME : \c "
read pass
active_transaction $imsi $DB_NAME $pass >> $CUBRID/tmp/cub_maintenance/stress_result/`date +"%Y%m%d"`/"$DB_NAME"_transaction.txt &
done
#####################################

############ CPU ####################
cpu_check $1  >> $CUBRID/tmp/cub_maintenance/stress_result/`date +"%Y%m%d"`/cpu.txt &
####################################

############ logtop ################
for Bro_name in broker1 query_editor
do
log_top $Bro_name
done
####################################

fi




