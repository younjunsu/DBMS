#!/bin/bash

# usage.
usage() {
cat <<EOF
Usage: $0  dbname <Enter>
EOF
}

# check user input.
if [ $# != 1 ]; then
        usage
        exit 1;
fi

dbname=$1

# check dbname.
if [ `grep -c -P "^\s*${dbname}\t+"  ${CUBRID_DATABASES}/databases.txt` == 0 ]; then
        echo "\"${dbname}\"가 존재하지 않습니다."
        exit 1;
fi

# check statdump.
cubrid statdump -i 1 ${dbname}@localhost | awk -f ~/junsu/statdump.awk 1>>statdump.log
#cubrid statdump -i 60 ${dbname}@localhost | awk -f ~/statdump.awk
