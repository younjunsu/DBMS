#!/bin/bash

############################ CUBRID environment variables. Start
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

############################ CUBRID environment variables. End



###################################### cub_jumgum.sh History Start
date +%Y%m%d >> $CUBRID/tmp/cub_maintenance/jumgum_result/jumgum_history.txt 
###################################### cub_jumgum.sh History End

###################################### Directorying Start
############### JumGum Dir
mkdir $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m` 2>/dev/null

############### Broekr_log tar.gz Dir
mkdir $CUBRID/tmp/maintenance/checkquery_dir/`date +%Y%m` 2>/dev/null
###################################### Directorying End.

###################################### Function List Start.

############### STEP_01. Default Platform Checking
function step_01(){
echo "[STEP_01. Default Platform Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	

echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
echo "@ Glibc" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "> `rpm -q glibc`" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
echo "@ Curses" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "> `rpm -q ncurses`" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
echo "@ Gcrypt " >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "> `rpm -q libgcrypt`" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
echo "@ Stdc++" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "> `rpm -q libstdc++`" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
}

############### STEP_02. Version Checking
function step_02(){
echo "[STEP_02. Version Checking]" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
##Cubrid Version
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cub_rel=`cubrid_rel |awk '{print $2}'|sed -n '2p' 2>/dev/null`

if [ $cub_rel -eq 2008 ] 2>/dev/null ; then
cub_rel=`cubrid_rel`
cub_rel_result=`echo $cub_rel |awk '{print $4}' |sed  's/(/ /g' | sed 's/)/ /g' 2>/dev/null `
echo "@ CUBRID Version : " >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "$cub_rel_result" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

else
cub_rel=`cubrid_rel`
cub_rel_result=`echo $cub_rel |awk '{print $3}' |sed  's/(/ /g' | sed 's/)/ /g'`
echo "@ CUBRID Version : " >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo $cub_rel_result >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
fi

## OS Version
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ OS Version : " >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cat /etc/*-release | uniq 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

## Kernel Version
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ Kernel Version : " >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
uname -r >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

## JDK or JRE Version
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ JDK or JRE Version : " >>$CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
java_ver=`rpm -qa | grep java 2>/dev/null`
if [ $java_ver -z ] 2>/dev/null ; then
echo "JDK or JRE None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
else
echo "$java_ver" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
fi
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_03. CUBRID DBMS Service Checking
function step_03(){
echo "[STEP_03. CUBRID DBMS Service Checking]" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
master_check=`ps -ef |grep cub_master |awk '{print $8}'|grep -v "grep" `

if [ -n master_check ] ; then
echo "@ cubrid master status" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "++ cubrid master is running." >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
else
echo "@ cubrid master status" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "++ cubrid manager server is not running." >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
fi
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ cubrid server status" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cubrid server status|sort |grep -v "@ cubrid server" 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

echo "@ Offline DB Name : " >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cubrid server status |sort|grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running." | awk '{print $2}'|sort 2>/dev/null > $CUBRID/tmp/cub_maintenance/on_db.txt
cat $CUBRID/databases/databases.txt  |awk '{print $1}'|grep -v "#db-name"|sort 2>/dev/null > $CUBRID/tmp/cub_maintenance/off_db.txt
diff $CUBRID/tmp/cub_maintenance/on_db.txt $CUBRID/tmp/cub_maintenance/off_db.txt 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log 
rm $CUBRID/tmp/cub_maintenance/on_db.txt $CUBRID/tmp/cub_maintenance/off_db.txt 2>/dev/null

echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

echo "@ cubrid broker status" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cubrid broker status -b|grep -v "@ cubrid broker status" 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

cubrid manager status 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ cubrid heartbeat list" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cubrid hb status |grep -v "@ cubrid heartbeat list" 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log


echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

manager_port=`cat $CUBRID/conf/cm.conf |grep cm_port|grep -v '#'|sed 's/cm_port/ /g'|sed 's/=/ /g' 2>/dev/null`
broker_port=`cat $CUBRID/conf/cubrid_broker.conf |grep BROKER_PORT|grep -v '#' | awk '{print $2}'|sed 's/=/ /g' 2>/dev/null`
cubrid_port=`cat $CUBRID/conf/cubrid.conf|grep cubrid_port|grep -v '#' |sed 's/cubrid_port_id=/ /g' 2>/dev/null`
ha_port=`cat $CUBRID/conf/cubrid_ha.conf|grep ha_port_id |grep -v '#'|sed 's/ha_port_id=/ /g' 2>/dev/null`
broker_port1=(`cat $CUBRID/conf/cubrid_broker.conf |grep BROKER_PORT |grep -v '#'| awk '{print $2}'|sed 's/=/ /g' 2>/dev/null`)

echo "@ CM PORT : $manager_port, 8002" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
netstat -nlp 2>/dev/null | grep $manager_port 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
netstat -nlp 2>/dev/null | grep 8002 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

echo "@ BROKER PORT : ${broker_port1[@]}" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
for((i=0; i<${#broker_port1};i++));do
netstat -nlp 2>/dev/null | grep ${broker_port1[i]} 2>/dev/null 
done >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

echo "@ CUBRID MASTER/SERVER PORT : $cubrid_port" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
netstat -nlp 2>/dev/null | grep $cubrid_port 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

echo "@ HA PORT : $ha_port" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
netstat -nlp 2>/dev/null | grep $ha_port 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

}

############### STEP_04. Linux Partitions Size Checking
function step_04(){
echo "[STEP_04. Linux Partitions Size Checking]" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
df -h 2>/dev/null >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_05. DB Volumes Size Checking
function step_05(){
echo "[STEP_05. DB Volumes Size Checking]" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

echo "@ DB Count : `cubrid server status| grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."|wc -l 2>/dev/null`" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

space_db=(`cubrid server status|grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."| awk '{print $2}'|sort 2>/dev/null`)
echo "--------------------------------------------------------------------" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
for((i=0;i<${#space_db[@]};i++)); do
echo "> DB Name : ${space_db[i]}";
cubrid spacedb -s ${space_db[i]}@localhost 2>/dev/null
echo "--------------------------------------------------------------------" 
echo
done >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_06. CUBRID DBMS Backup Checking
function step_06(){
echo "[STEP_06. CUBRID DBMS Backup Checking]">>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
 echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
db_path=(`cat $CUBRID/databases/databases.txt |grep -v "#db-name"|awk '{print $4}'`)
db_name=(`cat $CUBRID/databases/databases.txt |grep -v "#db-name"|awk '{print $1}'`)
y=0

for((i=0;i<${#db_path[@]};i++));do
ls_bkvinf=`ls -lrt $db_path/*bkvinf  2>/dev/null`

if [ -e ${db_path[i]}/*bkvinf ] ; then
echo "@ ${db_name[y]}"
bkvinf_path=`cat ${db_path[i]}/*bkvinf|awk '{print $3}' 2>/dev/null`

bk_file=`ls -lrth $bkvinf_path  2>/dev/null`
if [ $bk_file -z ] 2>/dev/null ; then
ls -lrth ${db_path[i]}/*bkvinf 2>/dev/null
echo "Backup File None"	
else
ls -lrth ${db_path[i]}/*bkvinf 2>/dev/null
ls -lrth $bkvinf_path  2>/dev/null
fi
echo

else
echo "@ ${db_name[y]}"
ls -lrth ${db_path[i]}/*bkvinf 2>/dev/null
echo "Backup File None"
echo
fi

y=$(($y+1))

done >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_07. CUBRID DBMS HA Sync Checking
function step_07(){
echo "[STEP_07. CUBRID DBMS HA Sync Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
 echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ HA DB Count : `cubrid server status| grep  "HA"|grep -v "++ cubrid master is not running."|wc -l`" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ cubrid heartbeat list" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cubrid hb status |grep -v "@ cubrid heartbeat list" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

ha_db=(`cubrid hb status|grep "Server "|awk '{print $2}'|sort`)
host_nm=`hostname`
remote_nm=`cubrid hb status|grep Node |grep -v "$host_nm"|awk '{print $2}'`

echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
for((i=0;i<${#ha_db[@]};i++));do
echo "@ DB Name : ${ha_db[i]}"
copy_path=`cubrid hb status |grep ${ha_db[i]}|grep -v "Copy"|grep -v "Server "|awk '{print $2}'|sed 's/@localhost/ /g'|awk '{print $2}'|sed 's/:/ /g'`
cubrid applyinfo -a -r $remote_nm -L $copy_path ${ha_db[i]} 
echo "--------------------------------------------------------------------"
done >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_08. CUBRID DBMS Active or Archives Log Checking
function step_08(){
echo "[STEP_08. CUBRID DBMS Active or Archives Log Checking]">>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

lists_db=(`cat $CUBRID/databases/databases.txt|grep -v "#db-name"|awk '{print $1}'|sort `)
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
for((i=0;i<${#lists_db[@]};i++));do
echo "@ DB Name : ${lists_db[i]}"

echo "> Parameter Checking"
param_check=`cubrid paramdump ${lists_db[i]}@localhost 2>/dev/null |grep -E "log_max_archives=|force_remove_log_archives=" `
if [ $param_check -z ] 2>/dev/null ; then
echo "Databases Not Running"
else
echo "$param_check"
fi
ac_count=`cubrid paramdump ${lists_db[i]}@localhost 2>/dev/null |grep log_max_archives=|grep -v "ha_copy_log_max_archives"|sed 's/log_max_archives=/ /g'`
ac_count=$(($ac_count+5))
lists_log=`cat $CUBRID/databases/databases.txt |grep ${lists_db[i]} |awk '{print $4}'`
echo
echo "> Active or Archive Log"
ls -lrth $lists_log |grep lgar|tail -$ac_count
echo

copy_check=`cat $CUBRID/conf/cubrid_ha.conf |grep ha_copy_log_base`
ha_check=`cat $CUBRID/conf/cubrid_ha.conf|grep ${lists_db[i]} `

if [ $copy_check -z ] 2>/dev/null ; then
copy_dir=`ls $CUBRID/databases |grep ${lists_db[i]} `
			if [ $copy_dir -z -a $ha_check -z ]; then
					echo "> Copylogdb Checking"
					echo "Not HA"
					echo
			else
			echo "> Copylogdb Checking : $CUBRID/databases/${lists_db[i]}*"
			ls -lrth $CUBRID/databases/${lists_db[i]}*
			fi
else
copy_base=`cat $CUBRID/conf/cubrid_ha.conf |grep ha_copy_log_base|sed 's/ha_copy_log_base=/ /g'`
			if [ $ha_check -z ] 2>/dev/null ; then
			echo "> Copylogdb Checking"
			echo "Not HA"
			echo
			else
			echo "> Copylogdb Checking : $copy_base/${lists_db[i]}*"
			ls -lrth $copy_base/${lists_db[i]}*
			fi
fi
echo "--------------------------------------------------------------------"
done >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_09. DB Parameters Checking
function step_09(){
echo "[STEP_09. DB Parameters Checking]" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "--------------------------------------------------------------------" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ cubrid.conf"  >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cat $CUBRID/conf/cubrid.conf |grep -v "#"|grep -v  "^$" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "--------------------------------------------------------------------" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ Online DB Count : `cubrid server status| grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."|wc -l`" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

lists_db=(`cubrid server status|grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."| awk '{print $2}'|sort`)
echo "--------------------------------------------------------------------" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
for((i=0;i<${#lists_db[@]};i++)); do
echo "@ DB Name : ${lists_db[i]}";
cubrid paramdump ${lists_db[i]}@localhost|grep -E "data_buffer_size=|max_clients=|java_stored_procedure=|isolation_level=|lock_escalation=|force_remove_log_archives=|log_max_archives=|ha_mode=|ha_copy_sync_mode=|ha_copy_log_base="
echo "--------------------------------------------------------------------"
echo
done >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_10. Broker Parameters Check
function step_10(){
echo "[STEP_10. Broker Parameters Check]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
 echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

cat $CUBRID/conf/cubrid_broker.conf|grep -A30 "%" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_11. Broker Status Checking
function step_11(){
echo "[STEP_11. Broker Status Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cubrid broker status -f -b >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_12. Recent ERR Log Checking
function step_12(){
echo "[STEP_12. Recent ERR Log Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
lists_db=(`cat $CUBRID/databases/databases.txt|grep -v "#db-name" |awk '{print $1}' |sort`)

	
old_date=`date -d '-1 month' +%Y%m`
old_date_result=`cat $CUBRID/tmp/cub_maintenance/jumgum_result/jumgum_history.txt |sort -r |grep $old_date|sed -n '1p'`
old_date_secon=`date -d $old_date_result +%s`
new_date_secon=`date +%s`
old_new_diff=`echo "($new_date_secon - $old_date_secon) / 86400" |bc`
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	

master_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$old_new_diff -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep"master"`
copy_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$old_new_diff -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "copylog"`
apply_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$old_new_diff -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "applylog"`
backup_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$old_new_diff -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "backupdb"`
echo "@ Master.err" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
if [ $master_err -z ]; then
	echo "> Master.err None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
else
echo "$master_err" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
fi
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
echo "@ Copylogdb.err" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
if [ $copy_err -z ]; then
echo "> Copylogdb.err None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
else
echo "$copy_err" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
fi
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
echo "@ Applylogdb.err" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
 if [ $apply_err -z ]; then
 	echo "> Applylogdb.err None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
else
echo "$apply_err" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
fi
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
echo "@ backupdb.err" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
if [ $backup_err -z ]; then
echo "> Backupdb.err None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
else
echo "$backup_err" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
fi
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	

for((i=0;i<${#lists_db[@]};i++));do
echo "@ Server.err / DB Name : ${lists_db[i]}"
find $CUBRID/log/server/${lists_db[i]}* -mtime -$old_new_diff -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' 
echo "--------------------------------------------------------------------"
done >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
}

############### STEP_13. CUBRID DBMS User Core File Checking
function step_13(){
echo "[STEP_13. CUBRID DBMS User Core File Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
 echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
user_count=`find ~/ -name 'core*' |wc -l`
engine_count=`find $CUBRID -name 'core*' |wc -l`
i=0
user_core=`find ~/ -name 'core*' -ls`
engine_core=`find $CUBRID -name 'core*' -ls`

if [ $user_count -gt $i ]; then
echo "@ User Path" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "[Index Number |?|chmod|Hard Link|User|Group|FileSzie|Time|Location]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "$user_core" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

else
echo "@ User Path Core File None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
fi

if [ $engine_count -gt $i ]; then
echo "@ Engine Path" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "[Index Number |?|chmod|Hard Link|User|Group|FileSzie|Time|Location]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "$engine_core" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
else
echo "@ Engine Path Core File None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
fi
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_14. CUBRID Owner user root File Checking
function step_14(){
echo "[STEP_14. CUBRID Owner user root File Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
user_count=`find ~/ -user root |wc -l`
engine_count=`find $CUBRID -user root |wc -l`
i=0
user_user=`find ~/ -user root -ls`
engine_user=`find $CUBRID -user root -ls`

if [ $user_count -gt $i ]; then
echo "@ User Path" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "[Index Number |?|chmod|Hard Link|User|Group|FileSzie|Time|Location]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "$user_user" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

else
echo "@ User Path root Owner File None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
fi

if [ $engine_count -gt $i ]; then
echo "@ Engine Path" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "[Index Number |?|chmod|Hard Link|User|Group|FileSzie|Time|Location]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "$engine_user" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
else
echo "@ Engine Path root Owner File None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
fi
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}

############### STEP_15. dmesg (CUBRID Owner User) Checking
function step_15(){
echo "[STEP_15. dmesg (CUBRID Owner User) Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
 echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
dmesg_count=`dmesg |grep cub_ |wc -l`
i=0
if [ $dmesg_count -gt $i ]; then
echo "@ dmesg Checking" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
 dmesg |grep cub_ >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
else
echo "@ dmesg None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
fi
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
	
}

############### STEP_16. Manager Auto Job Checking
function step_16(){
echo "[STEP_16. Manager Auto Job Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
ls -lrth $CUBRID/conf |grep auto >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
}

############### STEP_17. Server.err Fatal or Internal Checking
function step_17(){
echo "[STEP_17. Server.err Fatal or Internal Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	

lists_db=(`cat $CUBRID/databases/databases.txt|grep -v "#db-name" |awk '{print $1}' |sort`)

old_date=`date -d '-1 month' +%Y%m`
old_date_result=`cat $CUBRID/tmp/cub_maintenance/jumgum_result/jumgum_history.txt|sort -r |grep $old_date|sed -n '1p'`
old_date_secon=`date -d $old_date_result +%s`
new_date_secon=`date +%s`
old_new_diff=`echo "($new_date_secon - $old_date_secon) / 86400" |bc`
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	
for((i=0;i<${#lists_db[@]};i++));do
echo "@ DB Name : ${lists_db[i]}"
recent_err=(`find $CUBRID/log/server/${lists_db[i]}* -mtime -$old_new_diff 2>/dev/null`)

for((x=0;x<${#recent_err[@]};x++));do

recent_result=`cat ${recent_err[x]} | grep -E "fatal|internal" 2>/dev/null`

if [ $recent_result -z ] 2>/dev/null ; then
cat ${recent_err[x]} |grep -s "CUBRIID YOUNJUNSU" 2>/dev/null
else
echo "> File Name : ${recent_err[x]}"	
	cat ${recent_err[x]} | grep -A3 -E "fatal|internal" 2>/dev/null
fi

done
echo "--------------------------------------------------------------------"
done >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log	

}

############### STEP_18. Hosts File Checking
function step_18(){
echo "[STEP_18. Hosts File Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
 echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ Hosts Date File Checking" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
ls -rlth /etc/hosts >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "@ Hosts File Contents Checking" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cat /etc/hosts >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log

}

############### STEP_19. ulimit Checking
function step_19(){
echo "[STEP_19. ulimit Checking]" >>  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
 echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
i=0
ulimit_count=`ulimit -a |wc -l`
limit_count=`cat /etc/security/limits.conf |grep cub|wc -l`

if [ $ulimit_count -gt $i ]; then
echo "@ ulimit Checking" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
ulimit -a >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
else
echo "@ ulimit None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
fi

if [ $limit_count -gt $i ]; then
echo "limits.conf Checking" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
cat /etc/security/limits.conf |grep cub >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
else
echo "@ limits.conf None" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
fi
}

###################################### Function List End.


###################################### sub Function List Start
function sub_01(){
#echo "--------------------------------------------------------------------" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
#echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo "********************************************************************" >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
echo >> $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/`date +%Y%m%d`_jumgum.log
}
###################################### sub Function End.


###################################### Function Start.
step_01
sub_01

step_02
sub_01

step_03
sub_01

step_04
sub_01

step_05
sub_01

step_06
sub_01

step_07
sub_01

step_08
sub_01

step_09
sub_01

step_10
sub_01

step_11
sub_01

step_12
sub_01

step_13
sub_01

step_14
sub_01

step_15
sub_01

step_16
sub_01

step_17
sub_01

step_18
sub_01

step_19
sub_01
###################################### Function End.
