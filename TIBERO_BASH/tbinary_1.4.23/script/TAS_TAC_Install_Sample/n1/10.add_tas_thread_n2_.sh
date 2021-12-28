echo =================================
echo export TB_SID=tas1
echo
echo tbsql sys/tibero@tas1
echo 
echo alter diskspace ds0 add thread 1\;
echo =================================
echo

export TB_SID=tas1

tbsql sys/tibero@tas1 <<EOF

alter diskspace ds0 add thread 1;

quit
EOF
