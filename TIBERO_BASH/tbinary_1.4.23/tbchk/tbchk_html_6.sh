#!/usr/bin/ksh
#-------------------------------------------------------------------------------
# @File name      : tbchk_html.sh
# @Contents       : Tibero RDBMS CSR Ver1.0
# @Created by     : lee jun ho 
# @Created date   : 2019.05.03
# @Team           : DB Tech
# @Modifed History 
# ------------------------------------------------------------------------------
# 2019.05.03 lee jun ho                 (Ver1.0)
# ------------------------------------------------------------------------------

DT=`date +%Y%m%d`

function tmp_data1(){
rm -rf CPU_DT.txt

vmstat 1 5 >> CPU_DT.txt

echo "<p>[참조] 6.1 Current cpu usage</p><p>"
while read CPU_CHK
do
    echo $CPU_CHK "<br>"
done < CPU_DT.txt

rm -rf CPU_DT.txt

echo "</p>"
}

function tmp_data2(){
echo "<p>[참조] 7. File system check</p><p>"
df -k | while read F_CHK
do
    echo $F_CHK "<br>"
done
}

function tmp_data3(){
echo "<p>[참조] 8. Alet Log</p><p>"
find $TB_HOME/instance/$TB_SID/* -name "tbsvr.*" -print | xargs ls -alt | while read F_CHK
do
    echo $F_CHK "<br>"
done
}


tbsql -s sys/tibero <<EOF > TBCHK_6_$DT.html
set head off
set linesize 150
set feed off
@./html_sql/html_sql1.sql
quit
EOF

T=`tbdown pid| grep WP | wc -l`
tbsql -s sys/tibero << EOF >> TBCHK_6_$DT.html
set head off
set linesize 150
set feed off
select case when value = $T then '일치'
            else '불일치'
       end
from vt_parameter where name = 'WTHR_PROC_CNT';
quit
EOF

tbsql -s sys/tibero <<EOF >> TBCHK_6_$DT.html
set head off
set linesize 150
set feed off
@./html_sql/html_sql2.sql
quit
EOF

tbsql -s sys/tibero <<EOF >> TBCHK_6_$DT.html
set head off
set linesize 150
set feed off
@./html_sql/html_sql3.sql
quit
EOF

echo "<br>" >> TBCHK_6_$DT.html
tmp_data1 >> TBCHK_6_$DT.html

echo "<br>" >> TBCHK_6_$DT.html
tmp_data2 >> TBCHK_6_$DT.html

echo "<br>" >> TBCHK_6_$DT.html
tmp_data3 >> TBCHK_6_$DT.html

tbsql -s sys/tibero <<EOF >> TBCHK_6_$DT.html
set head off
set linesize 150
set feed off
@./html_sql/html_sql4.sql
quit
EOF
