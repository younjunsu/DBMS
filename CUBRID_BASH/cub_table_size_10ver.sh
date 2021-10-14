QUERY="SELECT class_name,is_system_class FROM db_class WHERE is_system_class='NO' ORDER BY class_name"
DB_NAME=zbxe
DB_USER=dba
DB_PASSWORD=

TABLE_PAGE_SIZE=`cubrid spacedb $DB_NAME@localhost |grep "log pagesize" |awk '{print $NF}' |sed 's/)//g' |sed 's/K//g'`
TABLE_LISTS=(`csql -u dba zbxe -c "$QUERY"|grep -vE "class_name|===|rows selected|^$" |sed "s/'//g"|awk '{print $1}'`)

echo "TABLE NAME || TABLE SIZE (KB)"

TABLE_TOTAL_SIZE=0
for TABLE_NAME in ${TABLE_LISTS[@]}
do
    if [ $DB_PASSWORD -z ]; then
        TABLE_HEAP=`csql -u $DB_USER   $DB_NAME@localhost -l -c "SHOW HEAP CAPACITY OF $TABLE_NAME;" |grep -w "Num_pages" |awk '{print $3}'`
    else
        TABLE_HEAP=`csql -u $DB_USER -p $DB_PASSWORD  $DB_NAME@localhost -l -c "SHOW HEAP CAPACITY OF $TABLE_NAME;" |grep -w "Num_pages" |awk '{print $3}'`
    fi

    TABLE_SIZE=`echo "$TABLE_HEAP * $TABLE_PAGE_SIZE" |bc`

    TABLE_TOTAL_SIZE=`echo "$TABLE_SIZE + $TABLE_TOTAL_SIZE"|bc`
    echo "$TABLE_NAME       $TABLE_SIZE KB"
done
echo "----------------------------------------------------------"
echo "----------------------------------------------------------"

echo "TABLE TOTAL SIZE : $TABLE_TOTAL_SIZE KB"
