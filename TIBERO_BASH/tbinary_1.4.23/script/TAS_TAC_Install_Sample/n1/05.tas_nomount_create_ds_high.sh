echo ======================================================
echo High Redundancy
echo ------------------------------------------------------
echo export TB_SID=tas1
echo 
echo tbboot nomount
echo 
echo tbsql sys/tibero@tas1
echo 
echo create diskspace ds0 high redundancy
echo failgroup fg1 disk \'/dev/tibero-tas-disk0\' name disk0,
echo                    \'/dev/tibero-tas-disk1\' name disk1
echo failgroup fg2 disk \'/dev/tibero-tas-disk2\' name disk2,
echo                    \'/dev/tibero-tas-disk3\' name disk3
echo failgroup fg3 disk \'/dev/tibero-tas-disk4\' name disk4,
echo                    \'/dev/tibero-tas-disk5\' name disk5
echo attribute \'AU_SIZE\'=\'4M\'\;

echo ======================================================
echo 

export TB_SID=tas1
tbboot nomount
tbsql sys/tibero@tas1 <<EOF

create diskspace ds0 high redundancy
failgroup fg1 disk '/dev/tibero-tas-disk0' name disk0,
                   '/dev/tibero-tas-disk1' name disk1
failgroup fg2 disk '/dev/tibero-tas-disk2' name disk2,
                   '/dev/tibero-tas-disk3' name disk3
failgroup fg3 disk '/dev/tibero-tas-disk4' name disk4,
                   '/dev/tibero-tas-disk5' name disk5
attribute 'AU_SIZE'='4M';

quit
EOF
