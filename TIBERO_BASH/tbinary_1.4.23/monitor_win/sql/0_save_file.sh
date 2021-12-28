#!/bin/sh
###########################
# Creat Monitor Save File #
###########################
get_sql_version(){

  dyn_sql_file=`echo $1"."$TVER_CHK | sed 's/ //g'|awk -F. '{printf "%s_%s.%s", $1,$3,$2}'`
  #echo $dyn_sql_file
  #read tm

  # file exist check
  if [ -e $MONITOR/sql/$dyn_sql_file  ] ; then
    echo $dyn_sql_file
  else
    #echo "file not exist"
    dyn_sql_file=$1
    echo $dyn_sql_file
  fi

  cat $MONITOR/sql/$dyn_sql_file >> $2 
}

if [ -n "$TBINARY_PATH" ] ; then
  MONITOR=$TBINARY_PATH/monitor; export MONITOR
else
  MONITOR=$HOME/tbinary/monitor; export MONITOR
fi

SQL_DIR=$MONITOR/sql
SAVE_FILE=$MONITOR/sql/0_save_file.sql
TEMP_FILE=$MONITOR/sql/0_save_file_temp.sql

echo "prompt ==========================" > $SAVE_FILE
echo "prompt  Tibero Monitoring Report " >> $SAVE_FILE
echo "prompt ==========================" >> $SAVE_FILE
echo "!date"                             >> $SAVE_FILE

echo                           >> $SAVE_FILE
echo "-- 1.GENERAL"            >> $SAVE_FILE
echo                           >> $SAVE_FILE

cat $MONITOR/sql/1_instance.sql             >> $SAVE_FILE
cat $MONITOR/sql/1_parameter.sql            >> $SAVE_FILE
cat $MONITOR/sql/1_sga.sql                  >> $SAVE_FILE
cat $MONITOR/sql/1_used_memory.sql          >> $SAVE_FILE
cat $MONITOR/sql/1_backup_status.sql        >> $SAVE_FILE


echo                           >> $SAVE_FILE
echo "-- 2.SHARED MEMORY"      >> $SAVE_FILE
echo                           >> $SAVE_FILE

cat $MONITOR/sql/2_bchr.sql                 >> $SAVE_FILE
cat $MONITOR/sql/2_sharedcache.sql          >> $SAVE_FILE
cat $MONITOR/sql/2_latch.sql                >> $SAVE_FILE


echo                           >> $SAVE_FILE
echo "-- 3.SESSION"            >> $SAVE_FILE
echo                           >> $SAVE_FILE

#cat $MONITOR/sql/3_current_session.sql      >> $SAVE_FILE
get_sql_version 3_current_session.sql $SAVE_FILE
#cat $MONITOR/sql/3_run_session.sql          >> $SAVE_FILE
get_sql_version 3_run_session.sql $SAVE_FILE
#cat $MONITOR/sql/3_run_session_wait.sql     >> $SAVE_FILE
get_sql_version 3_run_session_wait.sql $SAVE_FILE
#cat $MONITOR/sql/3_running_sql.sql          >> $SAVE_FILE
get_sql_version 3_running_sql.sql $SAVE_FILE
#cat $MONITOR/sql/3_current_transaction.sql  >> $SAVE_FILE
get_sql_version 3_current_transaction.sql $SAVE_FILE
cat $MONITOR/sql/3_open_cursor.sql          >> $SAVE_FILE


echo                           >> $SAVE_FILE
echo "-- 4.WAIT EVENT/LOCK"    >> $SAVE_FILE
echo                           >> $SAVE_FILE

#cat $MONITOR/sql/4_blockinglock.sql         >> $SAVE_FILE
get_sql_version 4_blockinglock.sql $SAVE_FILE
#cat $MONITOR/sql/4_hierarchical_lock.sql    >> $SAVE_FILE
get_sql_version 4_hierarchical_lock.sql $SAVE_FILE
#cat $MONITOR/sql/4_lockinfo.sql             >> $SAVE_FILE
get_sql_version 4_lockinfo.sql $SAVE_FILE
#cat $MONITOR/sql/4_lockobj.sql              >> $SAVE_FILE
get_sql_version 4_lockobj.sql $SAVE_FILE
cat $MONITOR/sql/4_system_event.sql         >> $SAVE_FILE
cat $MONITOR/sql/4_session_event_all.sql    >> $SAVE_FILE
#cat $MONITOR/sql/4_session_wait.sql         >> $SAVE_FILE
get_sql_version 4_session_wait.sql $SAVE_FILE
cat $MONITOR/sql/4_sysstat.sql              >> $SAVE_FILE
cat $MONITOR/sql/4_jcnt.sql                 >> $SAVE_FILE
cat $MONITOR/sql/4_redonowait.sql           >> $SAVE_FILE


echo                           >> $SAVE_FILE
echo "-- 5.SPACE"              >> $SAVE_FILE
echo                           >> $SAVE_FILE

cat $MONITOR/sql/5_control.sql              >> $SAVE_FILE
cat $MONITOR/sql/5_logfile.sql              >> $SAVE_FILE
cat $MONITOR/sql/5_datafile.sql             >> $SAVE_FILE
cat $MONITOR/sql/5_tbs.sql                  >> $SAVE_FILE
cat $MONITOR/sql/5_temp_tbs.sql             >> $SAVE_FILE
cat $MONITOR/sql/5_undo.sql                 >> $SAVE_FILE
#cat $MONITOR/sql/5_undo_usage_type.sql      >> $SAVE_FILE
get_sql_version 5_undo_usage_type.sql $SAVE_FILE
cat $MONITOR/sql/5_tempseg_usage.sql        >> $SAVE_FILE
cat $MONITOR/sql/5_tempseg_tot_usage.sql    >> $SAVE_FILE


echo                           >> $SAVE_FILE
echo "-- 6.I/O"                >> $SAVE_FILE
echo                           >> $SAVE_FILE

cat $MONITOR/sql/6_fileio.sql               >> $SAVE_FILE
cat $MONITOR/sql/6_session_io.sql           >> $SAVE_FILE
cat $MONITOR/sql/6_loghistory.sql           >> $SAVE_FILE


echo                           >> $SAVE_FILE
echo "-- 7.OBJECT"             >> $SAVE_FILE
echo                           >> $SAVE_FILE

cat $MONITOR/sql/7_object_count.sql         >> $SAVE_FILE
cat $MONITOR/sql/7_invalid_count.sql        >> $SAVE_FILE
cat $MONITOR/sql/7_invalid_object.sql       >> $SAVE_FILE
#cat $MONITOR/sql/7_segment_size.sql         >> $SAVE_FILE
get_sql_version 7_segment_size.sql $SAVE_FILE


echo                           >> $SAVE_FILE
echo "-- 8.SQL"                >> $SAVE_FILE
echo                           >> $SAVE_FILE

#cat $MONITOR/sql/8_topquery.sql             >> $SAVE_FILE
get_sql_version 8_topquery.sql $SAVE_FILE
get_sql_version 8_check_static_query.sql $SAVE_FILE


cat $SAVE_FILE | grep -v -w "exit" > $TEMP_FILE
echo >> $TEMP_FILE
echo "exit" >> $TEMP_FILE
mv $TEMP_FILE $SAVE_FILE
