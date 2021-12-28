export TB_SID=tac1

tbsql -s sys/tibero << EOF

set lines 200
set feedback off
col name for a26
col FIRST_TIME for a20
col RESETLOGS_TIME for a20
col MIN_LOG_TIME for a20
col MAX_LOG_TIME for a20
col RESETLOGS_CHANGE# for 99999
select * from V\$BACKUP_ARCHIVED_LOG;
select * from V\$ARCHIVED_LOG;
select * from V\$ARCHIVE_DEST_FILES;

EOF

