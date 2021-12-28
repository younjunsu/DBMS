echo ===============================================================================
echo export TB_SID=tac1
echo
echo tbsql sys/tibero@tac1
echo 
echo create undo tablespace undo1 datafile \'+DS0/tac/datafile/undo1.dtf\' size 100M 
echo autoextend on next 10M maxsize 1G extent management local autoallocate\;
echo 
echo alter database add logfile thread 1 group 3 \'+DS0/tac/redo/log11.log\' size 10M\;
echo 
echo alter database add logfile thread 1 group 4 \'+DS0/tac/redo/log12.log\' size 10M\;
echo 
echo alter database add logfile thread 1 group 5 \'+DS0/tac/redo/log13.log\' size 10M\;
echo 
echo alter database enable public thread 1\;
echo ===============================================================================





export TB_SID=tac1

tbsql sys/tibero@tac1 <<EOF

create undo tablespace undo1 datafile '+DS0/tac/datafile/undo1.dtf' size 100M autoextend on next 10M maxsize 1G extent management local autoallocate ;

alter database add logfile thread 1 group 3 '+DS0/tac/redo/log11.log' size 10M;

alter database add logfile thread 1 group 4 '+DS0/tac/redo/log12.log' size 10M;

alter database add logfile thread 1 group 5 '+DS0/tac/redo/log13.log' size 10M;

alter database enable public thread 1;

quit
EOF
