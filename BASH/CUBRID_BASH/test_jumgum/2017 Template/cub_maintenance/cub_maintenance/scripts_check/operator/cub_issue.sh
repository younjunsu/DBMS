#!/bin/bash

############################ CUBRID environment variables. Start
nodat_cub=`ls ~/cubrid.sh 2>/dev/null `
dat_cub=`ls ~/.cubrid.sh  2>/dev/null`

if [ $dat_cub -z ] 2>/dev/null; then
	if [ $nodat_cub -z ] 2>/dev/null; then
	echo "Need to check CUBRID environment variables. "
	else
		. ~/cubrid.sh
	fi
else
	. ~/.cubrid.sh
fi

############################ CUBRID environment variables. End


###################################### Function Lists Start
############### Broker Log, Utility Log, Server Log Backup
function step_00(){
	mkdir $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M` 2>/dev/null
	checkquery_dir=`cat $CUBRID/conf/cubrid_broker.conf |grep -r "LOG_DIR" |grep -v 'error'|grep -v '#'|awk '{print $2}'|sed 's/=/ /g'`
	checkquery_array=(`cat $CUBRID/conf/cubrid_broker.conf |grep -r "LOG_DIR" |grep -v 'error'|grep -v '#'|awk '{print $2}'|sed 's/=/ /g'|uniq`)
	broker_dir1=" log/broker/sql_log"
	
	for((i=0;i < ${#checkquery_array[@]};i++));do
	if [ ${checkquery_array[i]} == $broker_dir1 ] 2>/dev/null ; then
	
	cd $CUBRID/log/broker
	nohup 2>>/dev/null tar -cvzf $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H-%M`_broker_$i.tar.gz * & 
else
	cd ${checkquery_array[i]}
	nohup 2>>/dev/null tar -cvzf $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H-%M`_broker_$i.tar.gz * & 
	
	fi
	done
	
	cd $CUBRID/log
	cubrid_dir=`echo $CUBRID"log" |sed -e 's/\///g'`
	util_dir=`find $CUBRID/log/  -maxdepth 1 -mtime -5 |grep -E "master|copylog|apply|backup" |sed -e 's/\///g'|sed -e 's/'"$cubrid_dir"'//g'`
	
	nohup 2>>/dev/null tar -cvzf $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H-%M`_utillog.tar.gz `echo "$util_dir"` &
	
	
	
	
	server_dir=` find $CUBRID/log/server -maxdepth 1 -mtime -5 |sed -e 's/\///g' | sed -e 's/'"$cubrid_dir"'//g' |sed 's/logserver/server\//g'`
	nohup 2>>/dev/null tar -cvzf $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H-%M`_serverlog.tar.gz `echo "$server_dir"` &
	
	cd $CUBRID/tmp/cub_maintenance/scripts_check/engineer
}

############### CUBRID DBMS Service Checking
function step_01(){
echo "[STEP_01. CUBRID DBMS Service Checking]"  
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
echo "--------------------------------------------------------------------"  
echo
echo "@ Process"
ps -ef |grep cub
echo "--------------------------------------------------------------------"  
echo
echo

}			

############### CUBRID Broker Service Checking
function step_02(){
echo "[STEP_02. CUBRID Broker Service Checking]" 
echo "********************************************************************"  
cubrid broker status -f
echo "--------------------------------------------------------------------"  
echo
echo

}

############### Recent ERR Log Checking
function step_03(){
echo "[STEP_03. Recent ERR Log Checking]"  
echo "********************************************************************"  
lists_db=(`cat $CUBRID/databases/databases.txt|grep -v "#db-name" |awk '{print $1}' |sort`)
echo "--------------------------------------------------------------------"  	
echo -e "Input A few days ago :   \c                 "
input_date=5
master_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep"master" 2>/dev/null`
copy_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "copylog" 2>/dev/null`
apply_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "applylog" 2>/dev/null`
backup_err=`find $CUBRID/log/  -maxdepth 1 -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' | grep "backupdb" 2>/dev/null`
echo "@ Master.err"  	
if [ $master_err -z ]; then
	echo "> Master.err None"  	
else
echo "$master_err"  |more 	
fi
echo "--------------------------------------------------------------------"  	
echo "@ Copylogdb.err"  	
if [ $copy_err -z ] 2>/dev/null; then
echo "> Copylogdb.err None"  	
else
echo "$copy_err"  	|more
fi
echo "--------------------------------------------------------------------"  	
echo "@ Applylogdb.err"  	
 if [ $apply_err -z ] 2>/dev/null; then
 	echo "> Applylogdb.err None"  	
else
echo "$apply_err"  	|more
fi
echo "--------------------------------------------------------------------"  	
echo "@ backupdb.err"  	
if [ $backup_err -z ] 2>/dev/null; then
echo "> Backupdb.err None"  	
else
echo "$backup_err"  	|more
fi
echo "--------------------------------------------------------------------"  	

for((i=0;i<${#lists_db[@]};i++));do
echo "@ Server.err / DB Name : ${lists_db[i]}"
server_err=`find $CUBRID/log/server/${lists_db[i]}* -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}'`

if [ $server_err -z ] 2>/dev/null; then
echo "> Server.err None"
else
find $CUBRID/log/server/${lists_db[i]}* -mtime -$input_date -ls |awk '{print $3" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' |more
fi
echo "--------------------------------------------------------------------"
done  	
echo
echo
}

############### Linux Partitions Size Checking
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
echo
echo

}

############### DB Volumes Size Checking
function step_05(){
echo "[STEP_05. DB Volumes Size Checking]"  
echo "********************************************************************"  
echo "@ DB Count : `cm_admin listdb|wc -l 2>/dev/null`"  
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
echo "> DB is Not Running"
echo
echo "--------------------------------------------------------------------" 
fi
done
echo
echo
}

############### Shared Memory Checking
function step_06(){
echo "[STEP_06. Shared Memory Checking]"  
echo "********************************************************************"  
ipcs -a
echo
echo
}

############### CUBRID Lockdb Checking
function step_07(){
echo "[STEP_07. CUBRID Lockdb Checking]"  
echo "********************************************************************"  

lists_db=(`cat $CUBRID/databases/databases.txt|grep -v "#db-name"|awk '{print $1}'|sort `)

for((i=0;i<${#lists_db[@]};i++));do
echo "@ DB Name : ${lists_db[i]}"
cubrid lockdb ${lists_db[i]}@localhost 2>/dev/null
echo "--------------------------------------------------------------------"
echo
echo
done  
echo  	
}

############### CUBRID Lockdb Checking
function step_07_sub(){
echo "[STEP_07. CUBRID Lockdb Checking]"  
echo "********************************************************************" 
echo "> File Open"
ls -rlth $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/
}

############### dmesg Checking
function step_08(){
echo "[STEP_08. dmesg Checking]"  
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
echo
}

############### CUBRID DBMS User Core File Checking
function step_09(){
echo "[STEP_09. CUBRID DBMS User Core File Checking]"  
echo "********************************************************************"  
user_count=`find ~/ -name 'core*' |wc -l`
engine_count=`find $CUBRID -name 'core*' |wc -l`
i=0
user_core=`find ~/ -name 'core*' -ls`
engine_core=`find $CUBRID -name 'core*' -ls`

if [ $user_count -gt $i ]; then
echo "@ User Path"  
echo
echo "$user_core"  
echo "--------------------------------------------------------------------"  
echo  

else
echo "@ User Path Core File None"  
echo "--------------------------------------------------------------------"  
fi
echo
echo
if [ $engine_count -gt $i ]; then
echo "@ Engine Path"  
echo
echo "$engine_core"  
echo "--------------------------------------------------------------------"  
else
echo "@ Engine Path Core File None"  
echo "--------------------------------------------------------------------"  
fi
echo
echo 
}

###################################### Function Lists End.


###################################### Function Start.
old_tm=`date +%s`
step_00 
new_tm=`date +%s`
time_0=$(($new_tm-$old_tm))
issue_0=done;

old_tm=`date +%s`
step_01 >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_issue.log
new_tm=`date +%s`
time_1=$(($new_tm-$old_tm))
issue_1=done;

old_tm=`date +%s`
step_02 >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_issue.log
new_tm=`date +%s`
time_2=$(($new_tm-$old_tm))
issue_2=done;

old_tm=`date +%s`
step_03 >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_issue.log
new_tm=`date +%s`
time_3=$(($new_tm-$old_tm))
issue_3=done;

old_tm=`date +%s`
step_04 >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_issue.log
new_tm=`date +%s`
time_4=$(($new_tm-$old_tm))
issue_4=done;

old_tm=`date +%s`
step_05 >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_issue.log
new_tm=`date +%s`
time_5=$(($new_tm-$old_tm))
issue_5=done;

old_tm=`date +%s`
step_06 >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_issue.log
new_tm=`date +%s`
time_6=$(($new_tm-$old_tm))
issue_6=done;

old_tm=`date +%s`
step_07 >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_lockdb.log
step_07_sub >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_issue.log
new_tm=`date +%s`
time_7=$(($new_tm-$old_tm))
issue_7=done;

old_tm=`date +%s`
step_08 >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_issue.log
new_tm=`date +%s`
time_8=$(($new_tm-$old_tm))
issue_8=done;

old_tm=`date +%s`
step_09 >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_issue.log
new_tm=`date +%s`
time_9=$(($new_tm-$old_tm))
issue_9=done;

###################################### Function End.

###################################### Output Start.
cd $CUBRID/tmp/cub_maintenance/scripts_check/engineer
echo "[CUBRID DBMS Service Issue Checking]"
echo "[CUBRID DBMS Service Issue Checking]" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

echo "> Issue Result Files Path : $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`" 
echo "> Issue Result Files Path : $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

echo "Issue Checking. 1. CUBRID Service Status : $issue_1 : $time_1 sec"
echo "Issue Checking. 1. CUBRID Service Status : $issue_1 : $time_1 sec" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

echo "Issue Checking. 2. CUBRID Broker Status : $issue_2 : $time_2 sec"
echo "Issue Checking. 2. CUBRID Broker Status : $issue_2 : $time_2 sec" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

echo "Issue Checking. 3. CUBRID Recent Server Err : $issue_3 : $time_3 sec"
echo "Issue Checking. 3. CUBRID Recent Server Err : $issue_3 : $time_3 sec" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

echo "Issue Checking. 4. CUBRID Partitions Size : $issue_4 : $time_4 sec"
echo "Issue Checking. 4. CUBRID Partitions Size : $issue_4 : $time_4 sec" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

echo "Issue Checking. 5. CUBRID Volumes Size : $issue_5 : $time_5 sec"
echo "Issue Checking. 5. CUBRID Volumes Size : $issue_5 : $time_5 sec" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

echo "Issue Checking. 6. CUBRID Shared Memory : $issue_6 : $time_6 sec"
echo "Issue Checking. 6. CUBRID Shared Memory : $issue_6 : $time_6 sec" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

echo "Issue Checking. 7. CUBRID Lockdb : $issue_7 : $time_7 sec"
echo "Issue Checking. 7. CUBRID Lockdb : $issue_7 : $time_7 sec" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

echo "Issue Checking. 8. CUBRID dmesg : $issue_8 : $time_8 sec"
echo "Issue Checking. 8. CUBRID dmesg : $issue_8 : $time_8 sec" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

echo "Issue Checking. 9. CUBRID Core Files : $issue_9 : $time_9 sec"
echo "Issue Checking. 9. CUBRID Core Files : $issue_9 : $time_9 sec" >> $CUBRID/tmp/cub_maintenance/issue_result/`date +%Y%m%d-%H:%M`/`date +%Y%m%d-%H:%M`_running.log

###################################### Output End.

