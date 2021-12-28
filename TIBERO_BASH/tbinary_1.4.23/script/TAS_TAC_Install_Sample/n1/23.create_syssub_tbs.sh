echo ==================================================================
echo export TB_SID=tac1
echo 
echo tbsql sys/tibero@tac1 
echo
echo create tablespace syssub datafile \'+DS0/tac/datafile/tpr_ts.dtf\' 
echo size 10m reuse autoextend on next 10m\;
echo ==================================================================
echo

export TB_SID=tac1
tbsql sys/tibero@tac1 <<EOF

create tablespace syssub datafile '+DS0/tac/datafile/tpr_ts.dtf' size 10m reuse autoextend on next 10m;

quit
EOF

