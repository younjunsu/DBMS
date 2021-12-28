echo ========================================
echo External Redundancy
echo ----------------------------------------
echo export TB_SID=tas1
echo
echo tbboot nomount
echo
echo tbsql sys/tibero@tas1 
echo
echo create diskspace ds0 external redundancy
echo disk \'/dev/tibero-tas-disk0\' name disk0,
echo      \'/dev/tibero-tas-disk1\' name disk1,
echo      \'/dev/tibero-tas-disk2\' name disk2
echo      \'/dev/tibero-tas-disk3\' name disk3
echo      \'/dev/tibero-tas-disk4\' name disk4
echo      \'/dev/tibero-tas-disk5\' name disk5
echo attribute \'AU_SIZE\'=\'4M\'\;
echo ========================================
echo


export TB_SID=tas1
tbboot nomount
tbsql sys/tibero@tas1 <<EOF

create diskspace ds0 external redundancy
disk '/dev/tibero-tas-disk0' name disk0,
     '/dev/tibero-tas-disk1' name disk1,
     '/dev/tibero-tas-disk2' name disk2,
     '/dev/tibero-tas-disk3' name disk3,
     '/dev/tibero-tas-disk4' name disk4,
     '/dev/tibero-tas-disk5' name disk5
attribute 'AU_SIZE'='4M';

quit
EOF
