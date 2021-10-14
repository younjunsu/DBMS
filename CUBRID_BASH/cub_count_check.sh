#ex) dba
DB_USER=

#ex) DB Name
DB_NAME=

#ex) DB Password
DB_PSW=

#ex)FIle Directory and File Name
FILE_DIR=

table_lists=(`csql -u $DB_USER $DB_NAME@localhost -p $DB_PSW -c "select class_name from db_class where is_system_class='NO' and class_type='CLASS'"|grep -vE "class_name|======================|<Result of|rows selected|Committed.|^$"|sed "s/'//g"|awk '{print $1}'`)

for tb_nm in ${table_lists[@]}
do
    echo -n $tb_nm" count : " >> $FILE_DIR
    printf "%20s" >> $FILE_DIR
    csql -u $DB_USER $DB_NAME@localhost -p $DB_PSW -c "SELECT count(*) FROM $tb_nm;" |grep -vE "class_name|======================|<Result of|rows selected|Committed.|count\(|=========|^$"|awk '{print $1}' >> $FILE_DIR
done
