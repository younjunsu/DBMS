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

log_top(){
Bro_name=$1
default_dir="log/broker/sql_log"
log_dir=`cat $CUBRID/conf/cubrid_broker.conf |grep -i -A15 $Bro_name |grep LOG_DIR |grep -v '#'|grep -v 'error'|awk '{print $2}'|sed -s 's/=/ /g'`
if [ $log_dir == $default_dir ]
then
                cd $CUBRID/tmp/cub_maintenance/stress_result/`date +"%Y%m%d"`/
                broker_log_top $CUBRID/log/broker/sql_log/$Bro_name* 1>/dev/null
else
                cd $CUBRID/tmp/cub_maintenance/stress_result/`date +"%Y%m%d"`/
                broker_log_top $log_dir/$Bro_name* 1>/dev/null
fi
}


for Bro_name in broker1
do
log_top $Bro_name
done

