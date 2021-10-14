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



###################################### Function Lists Start

############### Main Output
function main_choice(){
echo " ******************************************************************** "
echo "  CUBRID Maintenace Checking Tool                                     "
echo " ******************************************************************** "
echo " * 1.Default Plattform              *  2.Version                      "
echo " ******************************************************************** "
echo " * 3.CUBRID Service                 *  4.Partition                    "
echo " ******************************************************************** "
echo " * 5.DBMS Volumes Size              *  6.DBMS Backup File             "
echo " ******************************************************************** "
echo " * 7.DBMS HA Sync                   *  8.DBMS Activelog/Archivelog    "
echo " ******************************************************************** "
echo " * 9.DBMS Parameter                 *  10.Broker Parameter            "
echo " ******************************************************************** "
echo " * 11.Broker Status                 *  12.Recent Server.err           "
echo " ******************************************************************** "
echo " * 13.CUBRID Core File              *  14.CUBRID Other Owner File     "
echo " ******************************************************************** "
echo " * 15.dmesg on CUBRID               *  16.CM Auto Jobs                "
echo " ******************************************************************** "
echo " * 17.CUBRID HA Constraints         *  18.hosts File                  "
echo " ******************************************************************** "
echo " * 19.ulimit and limist.conf        *  20.Error Code                  "
echo " ******************************************************************** "
echo " * 100.cub_jumgum.sh                *  200.sql_log tar                "
echo " ******************************************************************** "
}

############### cub_jumgum.sh Control
function jumgum(){
echo "[STEP_100. cub_jumgum.sh Control]" 
echo "********************************************************************" 
echo "* 1.cub_jumgum.sh Running          * 2.Jumgum File Checking         "
echo "********************************************************************"
echo -e " Input the Number : \c                 "
read input_jumgum
					case	$input_jumgum in
					1)
					clear
					echo "--------------------------------------------------------------------"  
					echo "@ cub_jumgum.sh Running"
					nohup sh 2>/dev/null $CUBRID/tmp/cub_maintenance/scripts_check/engineer/cub_jumgum.sh & 
					echo "> Process Checking"
					ps -ef |grep "cub_jumgum"|grep -v "grep"
					enter_check
					read;;
					
					2) 	
					
					echo "--------------------------------------------------------------------"  
					ls -d $CUBRID/tmp/cub_maintenance/jumgum_result/* |grep -v "jumgum_history.txt"
					
					echo "--------------------------------------------------------------------"  
					echo  "@ Jumgum File Checking : ($i/5) "
					echo -e " Input the Number (Format : YYYYmm / Default :`date +%Y%m`): \c                 "
					read month_checking
					echo "--------------------------------------------------------------------"  
					if [ $month_checking -z ] 2>/dev/null ; then
					ls  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/*
					else
					ls  $CUBRID/tmp/cub_maintenance/jumgum_result/$month_checking/*
					echo "--------------------------------------------------------------------"  
					echo
					fi
					echo -e "Continue 'y' : \c  "
					read msg_num

					check_num1="Y";
					check_num2="y"
					if [ $msg_num = $check_num1 -o $msg_num = $check_num2 ] 2>/dev/null; then
					clear
					jumgum_y
					else
				continue;
				fi
			esac
}

############### cub_jumgum.sh History
function jumgum_y(){
		echo "--------------------------------------------------------------------"  
					ls -d $CUBRID/tmp/cub_maintenance/jumgum_result/* |grep -v "jumgum_history.txt"
					
					echo "--------------------------------------------------------------------"  
					echo  "@ Jumgum File Checking"
					echo -e " Input the Number (Format : 201708 / Default :`date +%Y%m`): \c                 "
					read month_checking
					echo "--------------------------------------------------------------------"  
					if [ $month_checking -z ] 2>/dev/null ; then
					ls  $CUBRID/tmp/cub_maintenance/jumgum_result/`date +%Y%m`/*
					else
					ls  $CUBRID/tmp/cub_maintenance/jumgum_result/$month_checking/*
					echo "--------------------------------------------------------------------"  
					echo
					fi
					echo -e "Continue 'y' : \c  "
					read msg_num

					check_num1="Y";
					check_num2="y"
					if [ $msg_num = $check_num1 -o $msg_num = $check_num2 ] 2>/dev/null; then
					clear
					jumgum_y
					else
				continue;
				fi
}

############### SQL_LOG tar
function sql_log_tar(){
echo "[STEP_200. SQL_LOG tar]" 
echo "********************************************************************" 
echo "* 1.Broker_log_dir Checking               * 2.sql_log tar Starting    "
echo "********************************************************************"
echo "* 3.sql_log.tar.gz Checking               													"
echo "********************************************************************"
echo -e " Input the Number : \c                 "
read input_sql
checkquery_dir=`cat $CUBRID/conf/cubrid_broker.conf |grep -r "LOG_DIR" |grep -v 'error'|grep -v '#'|awk '{print $2}'|sed 's/=/ /g'`
checkquery_array=(`cat $CUBRID/conf/cubrid_broker.conf |grep -r "LOG_DIR" |grep -v 'error'|grep -v '#'|awk '{print $2}'|sed 's/=/ /g'|uniq`)
broker_dir1=" log/broker/sql_log"


case $input_sql in
	1)
	clear
  cat $CUBRID/conf/cubrid_broker.conf |grep -A 10 "%" |grep -E "%|LOG_DIR"
	echo -e "Input Continue ? (Continue : Y or y Input / Stop : Oter key Input) \c                 "
	read msg_num
	
	check_num1="Y";
	check_num2="y"
	if [ $msg_num = $check_num1 -o $msg_num = $check_num2 ] 2>/dev/null; then
		clear
		echo
	sql_log_tar
else
continue;
fi
	read;;
	2)
	clear
	mkdir $CUBRID/tmp/cub_maintenance/checkquery_result/`date +%Y%m` 2>/dev/null
	for((i=0;i < ${#checkquery_array[@]};i++));do
	if [ ${checkquery_array[i]} == $broker_dir1 ]; then
	
	
	cd $CUBRID/log/broker
	nohup 2>>/dev/null tar -cvzf $CUBRID/tmp/cub_maintenance/checkquery_result/`date +%Y%m`/`date +%Y%m%d`_broker_$i.tar.gz * & 
	echo "> Process Checking"
	ps -ef |grep "tar -cvzf"|grep -v "grep"
	else
	cd ${checkquery_array[i]}
	nohup 2>>/dev/null tar -cvzf $CUBRID/tmp/cub_maintenance/checkquery_result/`date +%Y%m`/`date +%Y%m%d`_broker_$i.tar.gz *& 
	echo "> Process Checking"
	ps -ef |grep "tar -cvzf"|grep -v "grep"
	fi
	done
	cd $CUBRID/tmp
	read;;
	
	3) 
	clear
	echo ""
	echo "> Checking Path : $CUBRID/tmp/cub_maintenance/checkquery_result/"
	ls -lrt $CUBRID/tmp/cub_maintenance/checkquery_result/
	echo
	echo -e "> Checking Path : $CUBRID/tmp/cub_maintenance/checkquery_result/\c"
	echo `date +%Y%m`"/*"
	ls -lrth $CUBRID/tmp/cub_maintenance/checkquery_result/`date +%Y%m`/*
	
	echo
	read;;
esac
}

############### dba password Input
function dba_pass_input(){
 echo -e " Input your DBA Password : \c"
 stty -echo
 read pass
 stty echo
 echo
}

############### enter_check 
function enter_check(){
echo
echo " Press Enter to continue..."
}

############### STEP_01. Default Platform Checking
function step_01(){
echo "[STEP_01. Default Platform Checking]" 
echo "********************************************************************" 
echo "--------------------------------------------------------------------"  
echo "@ Glibc"  
echo "> `rpm -q glibc`"  
echo "--------------------------------------------------------------------"  
echo "@ Curses"  
echo "> `rpm -q ncurses`"  
echo "--------------------------------------------------------------------"  
echo "@ Gcrypt "  
echo "> `rpm -q libgcrypt`"  
echo "--------------------------------------------------------------------"  
echo "@ Stdc++"  
echo "> `rpm -q libstdc++`"  
echo "--------------------------------------------------------------------" 
}

############### STEP_02. Version Checking
function step_02(){
echo "[STEP_02. Version Checking]"  
echo "********************************************************************"  

##Cubrid Version 
cub_rel=`cubrid_rel |awk '{print $2}'|sed -n '2p' 2>/dev/null`
echo "--------------------------------------------------------------------"  
if [ $cub_rel -eq 2008 ] 2>/dev/null ; then
cub_rel=`cubrid_rel`
cub_rel_result=`echo $cub_rel |awk '{print $4}' |sed  's/(/ /g' | sed 's/)/ /g' 2>/dev/null `
echo "@ CUBRID Version : "  
echo "$cub_rel_result"  
echo  

else
cub_rel=`cubrid_rel`
cub_rel_result=`echo $cub_rel |awk '{print $3}' |sed  's/(/ /g' | sed 's/)/ /g'`
echo "@ CUBRID Version : "  
echo $cub_rel_result  
echo  
fi

## OS Version
echo "--------------------------------------------------------------------"  
echo "@ OS Version : "  
cat /etc/*-release | uniq 2>/dev/null  
echo  

## Kernel Version
echo "--------------------------------------------------------------------"  
echo "@ Kernel Version : "  
uname -r  
echo  

## JDK or JRE Version
echo "--------------------------------------------------------------------"  
echo "@ JDK or JRE Version : "
java_ver=`rpm -qa | grep java 2>/dev/null`
if [ $java_ver -z ] 2>/dev/null ; then
echo "JDK or JRE None"  
else
echo "$java_ver"  
fi
echo "--------------------------------------------------------------------"  
}

############### STEP_03. CUBRID DBMS Service Checking
function step_03(){
echo "[STEP_03. CUBRID DBMS Service Checking]"  
echo "********************************************************************"  
master_check=`ps -ef |grep cub_master |awk '{print $8}'|grep -v "grep" `
echo "--------------------------------------------------------------------"  
if [ -n master_check ] ; then
echo "@ cubrid master status"  
echo "++ cubrid master is running."  
else
echo "@ cubrid master status"  
echo "++ cubrid manager server is not running."  
fi
echo  
echo "--------------------------------------------------------------------"  
echo "@ cubrid server status"  
cubrid server status|sort |grep -v "@ cubrid server" 2>/dev/null  
echo  

echo "@ Offline DB Name : "  
cubrid server status |sort|grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running." | awk '{print $2}'|sort 2>/dev/null > $CUBRID/tmp/cub_maintenance/on_db.txt
cat $CUBRID/databases/databases.txt  |awk '{print $1}'|grep -v "#db-name"|sort 2>/dev/null > $CUBRID/tmp/cub_maintenance/off_db.txt
diff $CUBRID/tmp/cub_maintenance/on_db.txt $CUBRID/tmp/cub_maintenance/off_db.txt 2>/dev/null   
rm $CUBRID/tmp/cub_maintenance/on_db.txt $CUBRID/tmp/cub_maintenance/off_db.txt 2>/dev/null
echo  
echo "--------------------------------------------------------------------"  
echo "@ cubrid broker status"  
cubrid broker status -b|grep -v "@ cubrid broker status" 2>/dev/null  
echo  

echo "--------------------------------------------------------------------"  
cubrid manager status 2>/dev/null  
echo  

echo "--------------------------------------------------------------------"  
echo "@ cubrid heartbeat list"  
cubrid hb status |grep -v "@ cubrid heartbeat list" 2>/dev/null  
echo  

echo
echo "[CUBRID Port Checking]"
echo "********************************************************************"  
echo "--------------------------------------------------------------------"  
manager_port=`cat $CUBRID/conf/cm.conf |grep cm_port|grep -v '#'|sed 's/cm_port/ /g'|sed 's/=/ /g' 2>/dev/null`
broker_port=`cat $CUBRID/conf/cubrid_broker.conf |grep BROKER_PORT|grep -v '#' | awk '{print $2}'|sed 's/=/ /g' 2>/dev/null`
cubrid_port=`cat $CUBRID/conf/cubrid.conf|grep cubrid_port|grep -v '#' |sed 's/cubrid_port_id=/ /g' 2>/dev/null`
ha_port=`cat $CUBRID/conf/cubrid_ha.conf|grep ha_port_id |grep -v '#'|sed 's/ha_port_id=/ /g' 2>/dev/null`
broker_port1=(`cat $CUBRID/conf/cubrid_broker.conf |grep BROKER_PORT |grep -v '#'| awk '{print $2}'|sed 's/=/ /g' 2>/dev/null`)

echo "@ CM PORT : $manager_port, 8002"  
netstat -nlp 2>/dev/null | grep $manager_port 2>/dev/null  
netstat -nlp 2>/dev/null | grep 8002 2>/dev/null  
echo  

echo "--------------------------------------------------------------------"  
echo "@ BROKER PORT : ${broker_port1[@]}"  
for((i=0; i<${#broker_port1};i++));do
netstat -nlp 2>/dev/null | grep ${broker_port1[i]} 2>/dev/null 
done  
echo  

echo "--------------------------------------------------------------------"  
echo "@ CUBRID MASTER/SERVER PORT : $cubrid_port"  
netstat -nlp 2>/dev/null | grep $cubrid_port 2>/dev/null  
echo  

echo "--------------------------------------------------------------------"  
echo "@ HA PORT : $ha_port"  
netstat -nlp 2>/dev/null | grep $ha_port 2>/dev/null  
echo  

}

############### STEP_04. Linux Partitions Size Checking
function step_04(){
echo "[STEP_04. Linux Partitions Size Checking]"  
echo "********************************************************************" 
echo "--------------------------------------------------------------------"  
echo "@ CUBRID Engine : $CUBRID"
echo "--------------------------------------------------------------------"  
echo "@ CUBRID DB DATA : "
cat $CUBRID/databases/databases.txt
echo "--------------------------------------------------------------------"  
echo "@ Partition Size"
df -h 2>/dev/null 
echo "--------------------------------------------------------------------"  
}

############### STEP_05. DB Volumes Size Checking
function step_05(){
echo "[STEP_05. DB Volumes Size Checking]"  
echo "********************************************************************"  
echo "@ DB Count : `cm_admin listdb|wc -l 2>/dev/null`"  
#space_db=(`cubrid server status|grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."| awk '{print $2}'|sort 2>/dev/null`)
space_db=(`cm_admin listdb |awk '{print $2}'|sort`)
echo "--------------------------------------------------------------------"  
for((i=0;i<${#space_db[@]};i++)); do
echo "> DB Name : ${space_db[i]}";
space_check=`cubrid spacedb -s ${space_db[i]}@localhost 2>&1 |grep "Failed to connect to database"`
if [ $space_check -z ] 2>/dev/null; then
cubrid spacedb -s ${space_db[i]}@localhost
echo
echo "--------------------------------------------------------------------" 
else
echo "- DB is Not Running"
echo
echo "--------------------------------------------------------------------" 
fi
done  
}

############### STEP_06. CUBRID DBMS Backup Checking
function step_06(){
echo "[STEP_06. CUBRID DBMS Backup Checking]" 
echo "********************************************************************"  
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

done
}

############### STEP_07. CUBRID DBMS HA Sync Checking
function step_07(){
echo "[STEP_07. CUBRID DBMS HA Sync Checking]"  
echo "********************************************************************"  
echo "@ HA DB Count : `cubrid server status| grep  "HA"|grep -v "++ cubrid master is not running."|wc -l`"  
echo "@ cubrid heartbeat list"  
cubrid hb status |grep -v "@ cubrid heartbeat list"  

ha_db=(`cubrid hb status|grep "Server "|awk '{print $2}'|sort`)
host_nm=`hostname`
remote_nm=`cubrid hb status|grep Node |grep -v "$host_nm"|awk '{print $2}'`

echo "--------------------------------------------------------------------"  
for((i=0;i<${#ha_db[@]};i++));do
echo "@ DB Name : ${ha_db[i]}"
copy_path=`cubrid hb status |grep ${ha_db[i]}|grep -v "Copy"|grep -v "Server "|awk '{print $2}'|sed 's/@localhost/ /g'|awk '{print $2}'|sed 's/:/ /g'`
cubrid applyinfo -a -r $remote_nm -L $copy_path ${ha_db[i]} 
echo "--------------------------------------------------------------------"
done  
echo  
}

############### STEP_08. CUBRID DBMS Active or Archives Log Checking
function step_08(){
echo "[STEP_08. CUBRID DBMS Active or Archives Log Checking]" 
echo "********************************************************************"  

lists_db=(`cat $CUBRID/databases/databases.txt|grep -v "#db-name"|awk '{print $1}'|sort `)
echo "--------------------------------------------------------------------"  
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
apply_log_cnt=`ls $lists_log |grep lgar|wc -l`

echo "> Active or Archive Log  (Count : $apply_log_cnt)"
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
			copy_log_cnt=`ls $copy_base/${lists_db[i]}* |wc -l`
			
			echo "> Copylogdb Checking : $copy_base/${lists_db[i]}* (Count : $copy_log_cnt)"
			ls -lrth $copy_base/${lists_db[i]}*
			fi
fi
echo
echo
echo
echo "--------------------------------------------------------------------"
done  
}

############### STEP_09. DB Parameters Checking
function step_09(){
echo "[STEP_09. DB Parameters Checking]"  
echo "********************************************************************"  
echo "--------------------------------------------------------------------"  
echo "@ cubrid.conf"   
cat $CUBRID/conf/cubrid.conf |grep -v "#"|grep -v  "^$"  
echo "--------------------------------------------------------------------"  
echo "@ Online DB Count : `cubrid server status| grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."|wc -l`"  
echo  

lists_db=(`cubrid server status|grep -v "@ cubrid server status"|grep -v "++ cubrid master is not running."| awk '{print $2}'|sort`)
echo "--------------------------------------------------------------------"  
for((i=0;i<${#lists_db[@]};i++)); do
echo "@ DB Name : ${lists_db[i]}";
cubrid paramdump ${lists_db[i]}@localhost|grep -E "data_buffer_size=|max_clients=|java_stored_procedure=|isolation_level=|lock_escalation=|force_remove_log_archives=|log_max_archives=|ha_mode=|ha_copy_sync_mode=|ha_copy_log_base="
echo "--------------------------------------------------------------------"
echo
done  
}

############### STEP_10. Broker Parameters Check
function step_10(){
echo "[STEP_10. Broker Parameters Check]"  
echo "********************************************************************" 
cat $CUBRID/conf/cubrid_broker.conf|grep -A30 "%"  
}

############### STEP_11. Broker Status Checking
function step_11(){
echo "[STEP_11. Broker Status Checking]"  
echo "********************************************************************"
cubrid broker status -f -b  
echo  
}

############### STEP_12. Recent ERR Log Checking
function step_12(){
echo "[STEP_12. Recent ERR Log Checking]"  
echo "********************************************************************"  
lists_db=(`cat $CUBRID/databases/databases.txt|grep -v "#db-name" |awk '{print $1}' |sort`)

	

echo "--------------------------------------------------------------------"  	


echo -e "Input A few days ago :   \c                 "
read input_date

master_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep"master"`
copy_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "copylog"`
apply_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "applylog"`
backup_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "backupdb"`
echo "@ Master.err"  	
if [ $master_err -z ]; then
	echo "> Master.err None"  	
else
echo "$master_err"  |more 	
fi
echo "--------------------------------------------------------------------"  	
echo "@ Copylogdb.err"  	
if [ $copy_err -z ]; then
echo "> Copylogdb.err None"  	
else
echo "$copy_err"  	|more
fi
echo "--------------------------------------------------------------------"  	
echo "@ Applylogdb.err"  	
 if [ $apply_err -z ]; then
 	echo "> Applylogdb.err None"  	
else
echo "$apply_err"  	|more
fi
echo "--------------------------------------------------------------------"  	
echo "@ backupdb.err"  	
if [ $backup_err -z ]; then
echo "> Backupdb.err None"  	
else
echo "$backup_err"  	|more
fi
echo "--------------------------------------------------------------------"  	

for((i=0;i<${#lists_db[@]};i++));do
echo "@ Server.err / DB Name : ${lists_db[i]}"
server_err=`find $CUBRID/log/server/${lists_db[i]}* -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}'`

if [ $server_err -z ]; then
echo "> Server.err None"
else
find $CUBRID/log/server/${lists_db[i]}* -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' |more
fi
echo "--------------------------------------------------------------------"
done  	
}

############### STEP_13. CUBRID DBMS User Core File Checking
function step_13(){
echo "[STEP_13. CUBRID DBMS User Core File Checking]"  
echo "********************************************************************"  
user_count=`find ~/ -name 'core*' |wc -l`
engine_count=`find $CUBRID -name 'core*' |wc -l`
i=0
user_core=`find ~/ -name 'core*' -ls`
engine_core=`find $CUBRID -name 'core*' -ls`

if [ $user_count -gt $i ]; then
echo "@ User Path"  
echo "[Index Number |?|chmod|Hard Link|User|Group|FileSzie|Time|Location]"  
echo "$user_core"  
echo  

else
echo "@ User Path Core File None"  
echo  
fi

if [ $engine_count -gt $i ]; then
echo "@ Engine Path"  
echo "[Index Number |?|chmod|Hard Link|User|Group|FileSzie|Time|Location]"  
echo "$engine_core"  
else
echo "@ Engine Path Core File None"  
fi
echo  
}

############### STEP_14. CUBRID Owner user root File Checking
function step_14(){
echo "[STEP_14. CUBRID Owner user root File Checking]"  
echo "********************************************************************"  
user_count=`find ~/ -user root |wc -l`
engine_count=`find $CUBRID -user root |wc -l`
i=0
user_user=`find ~/ -user root -ls`
engine_user=`find $CUBRID -user root -ls`

if [ $user_count -gt $i ]; then
echo "@ User Path"  
echo "[Index Number |?|chmod|Hard Link|User|Group|FileSzie|Time|Location]"  
echo "$user_user"  
echo  

else
echo "@ User Path root Owner File None"  
echo  
fi

if [ $engine_count -gt $i ]; then
echo "@ Engine Path"  
echo "[Index Number |?|chmod|Hard Link|User|Group|FileSzie|Time|Location]"  
echo "$engine_user"  
else
echo "@ Engine Path root Owner File None"  
fi
echo  
}

############### STEP_15. dmesg (CUBRID Owner User) Checking
function step_15(){
echo "[STEP_15. dmesg (CUBRID Owner User) Checking]"  
echo "********************************************************************"  
dmesg_count=`dmesg |grep cub_ |wc -l`
i=0
if [ $dmesg_count -gt $i ]; then
echo "@ dmesg Checking"  
 dmesg |grep cub_  
else
echo "@ dmesg None"  
fi
echo  
	
}

############### STEP_16. Manager Auto Job Checking
function step_16(){
echo "[STEP_16. Manager Auto Job Checking]"  
echo "********************************************************************"  
echo "--------------------------------------------------------------------"  
ls -lrth $CUBRID/conf |grep auto  
echo "--------------------------------------------------------------------"  
}

############### STEP_17. CUBRID HA Constraints Checking
function step_17(){
echo "[STEP_17. CUBRID HA Constraints Checking]"  
echo "********************************************************************"  
cnt=1
echo "-------------------------------------"
echo " HA-Server List                      "
echo "-------------------------------------"
for DB_NAME in `cubrid server status | grep HA |sort| awk '{print $2}' `
do
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input HA-server Name    : \c               "
read choice_DB
        for DB_NAME in `cubrid server status | grep HA |sort| awk '{print $2}'`
        do
                if [ $choice_DB == $DB_NAME ]
                then
    
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
done
Master=`cubrid hb status | grep priority | grep master | awk '{print $2}'`
Slave=`cubrid hb status | grep priority | grep slave | awk '{print $2}' | sort | sed -n '1p'`

dba_pass_input
clear
if [ "$pass" != "" ]
then 
	pass=`echo "$pass"`
fi

error_psw=`csql -u dba -p "$pass" $choice_DB@localhost -c "SELECT 1" 2>&1|grep -v "ERROR: Incorrect or missing password."  |grep "Result of SELECT Command in Line 1"|grep -v  "^$"`

if [ $error_psw -z ] 2>/dev/null ; then
while [ $error_psw -z ] 2>/dev/null ;do
echo "@ $DB_NAME"
echo "> ERROR: Incorrect or missing password."
dba_pass_input
clear
if [ "$pass" != "" ]
then 
	pass=`echo "$pass"`
fi
error_psw=`csql -u dba -p "$pass" $choice_DB@localhost -c "SELECT 1" 2>&1|grep -v "ERROR: Incorrect or missing password."  |grep "Result of SELECT Command in Line 1"|grep -v  "^$"`

done
fi

ha_warning_list=`csql -u dba -p "$pass" -c "select 'NON_PK', class_name \
from db_class \
where class_type='CLASS' and is_system_class='NO' \
and class_name not in (select distinct class_name from db_index where is_primary_key='YES') \
union all select 'SP', sp_name from db_stored_procedure \
union all select data_type, class_name||' '||attr_name as table_column from db_attribute \
where data_type in ('CLOB','BLOB') \
union all select 'Serial Cache', name from db_serial where cached_num >0 " $choice_DB@$Master`
nonpk_no=`echo "$ha_warning_list" | sed '1,5d' | grep "NON_PK" | wc -l`
sp_no=`echo "$ha_warning_list" | sed '1,5d' |  grep "SP" |  wc -l`
clob_no=`echo "$ha_warning_list" | sed '1,5d' |  grep "CLOB" |  wc -l`
blob_no=`echo "$ha_warning_list" | sed '1,5d' |  grep "BLOB" |  wc -l`
serial_no=`echo "$ha_warning_list" | sed '1,5d' |  grep "Serial" | wc -l`

echo "===================================="
echo "        HA Warning Summary          "
echo "===================================="
echo "    case                  value     "
echo "------------------------------------"
echo "  'NON_PK'                  $nonpk_no"
echo "  'SP'                      $sp_no"
echo "  'CLOB'                    $clob_no"
echo "  'BLBO'                    $blob_no"
echo "  'Serial Cache'            $serial_no"
echo "===================================="
echo
echo
echo "===================================="
echo "           HA Warning List          " 
echo "===================================="
echo "    case                  value     "
echo "------------------------------------"
echo "$ha_warning_list" | sed '1,5d' | sed '$d'
echo "===================================="
echo
echo
echo -e " Do you confirm the comparison of the non_pk tables?(Y/N) : \c "
read answer
if [[ `echo $answer | grep "^[Yy]$\|^[Yy][Ee][Ss]$" | wc -l` -ge 1 ]]
then
clear
non_pk_list=`csql -u dba -p "$pass" -c "select 'NON_PK' x, class_name \
from db_class \
where class_type='CLASS' and is_system_class='NO' \
and class_name not in (select distinct class_name from db_index where is_primary_key='YES')" $choice_DB@$Master | grep "NON_PK" | awk '{print $2}'`
non_pk_total=`echo "$non_pk_list" | wc -l`
echo "======================================================================================"
echo "                                   NON PK Table Count                                 "
echo "======================================================================================"
echo " Table name                   Master           Slave            Diff         Progress "
echo "--------------------------------------------------------------------------------------"
cnt=1
for table_name in $non_pk_list
do
        progress=`expr $cnt \* 100 / $non_pk_total`
	table_name=${table_name/\'/}
	table_name=${table_name/\'/}
	Master_count=`csql -u dba -p "$pass" -c "select count(*) from $table_name" $choice_DB@$Master 2>&1 | sed -n 6p | awk '{print $1}'`
	Slave_count=`csql -u dba -p "$pass" -c "select count(*) from $table_name" $choice_DB@$Slave 2>&1 | sed -n 6p | awk '{print $1}'`
	if [ -z $Slave_count ]
	then
		Slave_count=0
	fi
	TDIFF=`expr $Master_count - $Slave_count 2>/dev/null`
	printf "%-20s %15d %15d %15d %15d" $table_name $Master_count $Slave_count $TDIFF $progress
	echo "%"
cnt=`expr $cnt + 1`
done
echo "======================================================================================"
fi
}

############### STEP_18. Hosts File Checking
function step_18(){
echo "[STEP_18. Hosts File Checking]"  
echo "********************************************************************"  
echo "@ Hosts Date File Checking"  
ls -rlth /etc/hosts  
echo "--------------------------------------------------------------------"  
echo "@ Hosts File Contents Checking"  
cat /etc/hosts  
echo "--------------------------------------------------------------------"  

}

############### STEP_19. ulimit Checking
function step_19(){
echo "[STEP_19. ulimit Checking]"  
 echo "********************************************************************"  
i=0
ulimit_count=`ulimit -a |wc -l`
limit_count=`cat /etc/security/limits.conf |grep cub|wc -l`
echo "--------------------------------------------------------------------"  
if [ $ulimit_count -gt $i ]; then
echo "@ ulimit Checking"  
ulimit -a  
echo "--------------------------------------------------------------------"  
else
echo "@ ulimit None"  
fi

if [ $limit_count -gt $i ]; then
echo "limits.conf Checking"  
cat /etc/security/limits.conf |grep cub  
else
echo "@ limits.conf None"  
fi
echo "--------------------------------------------------------------------"  
}

############### STEP_20. Error Msg Checking
function step_20(){
echo "[STEP_20. Error Msg Checking]"
echo "********************************************************************"
#i=1;
#while [ $i -le 3 ];do
echo -e "Input Error Code : \c                 "
read error_num
	if [ $error_num -z ] 2>/dev/null ; then
	echo
	step_20	
	else
	num_sed=`echo "$error_num""p"`
	en_msg=`cat $CUBRID/msg/en_US/cubrid.msg |grep -A1200 "set 5 MSGCAT_SET_ERROR"|grep -B2200 "set 6 MSGCAT_SET_INTERNAL"|grep -v "set 5 MSGCAT_SET_ERROR"|grep -v "$ LOADDB"|sed -n ''$num_sed'' 2>/dev/null`
	ko_msg=`cat $CUBRID/msg/ko_KR.utf8/cubrid.msg |grep -A1200 "set 5 MSGCAT_SET_ERROR"|grep -B2200 "set 6 MSGCAT_SET_INTERNAL"|grep -v "set 5 MSGCAT_SET_ERROR"|grep -v "$ LOADDB"|sed -n ''$num_sed'' 2>/dev/null`

	echo "--------------------------------------------------------------------"
	echo "Input Error Code : $error_num"
	echo "EN_msg : $en_msg"
	echo "KO_msg : $ko_msg"
	echo "--------------------------------------------------------------------"
	fi
echo -e "Input Continue ? (Continue : Y or y Input / Stop : Oter key Input) \c                 "
#echo -e "Input Continue ? (Continue : Y or y Input / Stop : Oter key Input)  /c                 "
read msg_num

check_num1="Y";
check_num2="y"
if [ $msg_num = $check_num1 -o $msg_num = $check_num2 ] 2>/dev/null; then
	clear
	echo
	step_20
else
continue;
fi
#i=$(($i+1))
#done
}

###################################### Function Lists End.

###################################### Function Start.
while(true) do
clear
main_choice
echo -e " Input the Number : \c                 "
read input_num1
case	$input_num1 in
	1)
	clear
	step_01 |more
	enter_check
	read;;	
	
	2)
	clear
	step_02 |more
	enter_check
	read;;
	
	3)
	clear
	step_03|more
	enter_check
	read;;
	
	4)
	clear
	step_04|more
	enter_check
	read;;
	
	5)
	clear
	step_05|more
	enter_check
	read;;
	
	6)
	clear
	step_06|more
	enter_check
	read;;
	
	7)
	clear
	step_07|more
	enter_check
	read;;
	
	8)
	clear
	step_08|more
	enter_check
	read;;
	
	9)
	clear
	step_09|more
	enter_check
	read;;
	
	10)	
	clear
	step_10|more
	enter_check
	read;;

	11)
	clear
	step_11 |more
	enter_check
	read;;	
	
	12)
	clear
	step_12 
	enter_check
	read;;
	
	13)
	clear
	step_13 |more
	enter_check
	read;;
	
	14)
	clear
	step_14 |more
	enter_check
	read;;
		
	15)
	clear
	step_15 |more
	enter_check
	read;;	
	
	16)
	clear
	step_16 |more
	enter_check
	read;;	
	
	17)
	clear
	step_17 
	enter_check
	read;;	
	
	18)
	clear
	step_18 |more
	enter_check
	read;;
	
	19)
	clear
	step_19 |more
	enter_check
	read;;	
	
	20)
	clear
	step_20 
	enter_check
	read;;	

	100)
	clear
	jumgum
	enter_check
	read;;

	200)
	clear
	sql_log_tar
	enter_check
	read;;
		
esac
done
###################################### Function End.
