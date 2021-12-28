#!/bin/bash
##########################################################
# Install Check Script.
# Apply : Tibero 4 over (recommend 4SP1 over)
##########################################################

_rfile=install_result.txt

if [ $# -ne 1 ]; then
        echo ""
        printf " ____________________________________\r Enter sys password [tibero] : "
        read syspw
        echo ""
fi

lnsp(){
        echo ""
        echo ""
}

runsql(){
        echo "$1">.fn_tmp
        echo "exit" >>.fn_tmp
        _str=$(echo $1|awk '{print $2}'|awk -F , '{print $1}')
        if [ $2 ]; then
                _rtn=$(tbsql -s sys/$syspw @.fn_tmp |egrep -iv "$_str|selected|disconnected")
        else
                _rtn=$(tbsql -s sys/$syspw @.fn_tmp |egrep -iv "$_str|----|selected|disconnected")
        fi
        \rm -rf .fn_tmp
}

# 0. tbsql 접속 확인
_ERR=false
conchk(){
err=$(tbsql -s sys/$syspw <<EOF
exit
EOF
)
if [ -n "`echo $err|grep -iv disconnected`" ]; then
        echo $err
        echo ""
        echo "Script abnomally terminated !!!!"
        echo ""
        _ERR=true
        exit -1
fi
runsql "select version from v\$instance;"
ver=$_rtn
}

# 1. 설치계정
fn1(){
echo "1. 설치계정"
echo "  - User : `whoami` / "
echo "  - DB(sys) Password : $syspw"
lnsp
}

# 2. 설치 디렉토리
fn2(){
echo "2. 설치 디렉토리"
echo "  - TB_HOME     : `echo $TB_HOME`"
runsql "select name from v\$datafile;"
echo "  - Datafile    : `echo "$_rtn"|sed 's/ /\n/g'|sed 's/^/                  /g'`"
runsql "select member from v\$logfile;"
echo "  - Redolog     : `echo "$_rtn"|sed 's/ /\n/g'|sed 's/^/                  /g'`"
runsql "select name from v\$controlfile;"
echo "  - Controlfile : `echo "$_rtn"|sed 's/ /\n/g'|sed 's/^/                  /g'`"
lnsp
}

# 3. 설정 내역
fn3(){
echo "3. 설정 내역"
runsql "select value from _vt_parameter where name='LISTENER_PORT';"
echo "  - Listener Port : `echo $_rtn`"
runsql "select log_mode from v\$database;"
echo "  - Log Mode      : `echo $_rtn`"
runsql "select value from _dd_props where name='NLS_CHARACTERSET';"
echo "  - Character Set : `echo $_rtn`"
runsql "select name from v\$database;"
echo "  - DB Name       : `echo $_rtn`"
lnsp
}

# 4. JDBC Library 위치
fn4(){
echo "4. JDBC Library 위치"
echo "  - JDK1.4 이하 : `echo $TB_HOME/client/lib/jar/tibero*-jdbc-14.jar`"
echo "  - JDK1.5 이상 : `echo $TB_HOME/client/lib/jar/tibero*-jdbc.jar`"
lnsp
}

# 5. Tibero 기동 명령
fn5(){
echo "5. Tibero 기동 명령"
echo "  $ tbboot"
lnsp
}

# 6. Tibero 종료 명령
fn6(){
echo "6. Tibero 종료 명령"
echo "  $ tbdown"
lnsp
}

# 7. Tibero 접속 방법
fn7(){
echo "7. Tibero 접속 방법"
echo "  $ tbsql Userid/Password[@alias]"
echo "  ex) tbsql sys/$syspw"
echo "      tbsql tibero/tmax@tibero2"
echo "  - alias : $TB_HOME/client/config/tbdsn.tbr 참조"
lnsp
}

# 8. Tibero 버전 정보
fn8(){
echo "8. Tibero 버전"
runsql "select * from v\$version;" view
echo "$_rtn"
lnsp

echo "tbboot -version"
echo ----------------------------------------------
tbboot -version

lnsp
}

# 9. Tibero 라이선스 정보
fn9(){
echo "9. Tibero 라이선스 정보"
runsql "set linesize 100
        col host format a20
        col license_type format a15
        col product_name format a15
        col product_version format a15
        col edition format a15
        select host,license_type,product_name,product_version,edition from v\$license;" view
echo "$_rtn"
runsql "set linesize 100
        col issue_date format a20
        col expire_date format a20
        col limit_user format a25
        col limit_cpu format a25
        select issue_date,expire_date,limit_user,limit_cpu from v\$license;" view
echo "$_rtn"
lnsp
}

# 10. Tablespace 정보
fn10(){
echo "10. Tablespace 정보"
#set feedback off
runsql "set linesize 120
col \"Tablespace Name\" format a20
col \"Bytes(MB)\"       format 999,999,999
col \"Used(MB)\"        format 999,999,999
col \"Percent(%)\"      format 9999999.99
col \"Free(MB)\"        format 999,999,999
col \"Free(%)\"         format 9999.99
col \"MaxBytes(MB)\"       format 999,999,999

SELECT ddf.tablespace_name \"Tablespace Name\",
       ddf.bytes/1024/1024 \"Bytes(MB)\",
       (ddf.bytes - dfs.bytes)/1024/1024 \"Used(MB)\",
       round(((ddf.bytes - dfs.bytes) / ddf.bytes) * 100, 2) \"Percent(%)\",
       dfs.bytes/1024/1024 \"Free(MB)\",
       round((1 - ((ddf.bytes - dfs.bytes) / ddf.bytes)) * 100, 2) \"Free(%)\",
       ROUND(ddf.MAXBYTES / 1024/1024,2) \"MaxBytes(MB)\"
FROM
 (SELECT tablespace_name, sum(bytes) bytes, sum(maxbytes) maxbytes
   FROM   dba_data_files
   GROUP BY tablespace_name) ddf,
 (SELECT tablespace_name, sum(bytes) bytes
   FROM   dba_free_space
   GROUP BY tablespace_name) dfs
WHERE ddf.tablespace_name = dfs.tablespace_name
ORDER BY ((ddf.bytes-dfs.bytes)/ddf.bytes) DESC;" view
echo "$_rtn"
runsql "set linesize 120
col \"Tablespace Name\" format a15 
col \"Location\"  format a60
col \"Size(MB)\" format 9,999,999.99
col \"MaxSize(MB)\" format 9,999,999.99

SELECT tablespace_name \"Tablespace Name\",
       file_name \"Location\" ,
       bytes/1024/1024 \"Size(MB)\",
       maxbytes/1024/1024 \"MaxSize(MB)\"
FROM dba_temp_files;" view
echo "$_rtn"
lnsp
}

# 11. 서비스 기동 확인
fn11(){
echo "11. 서비스 기동 확인"
tbdown pid
lnsp
}

# 12. 데이터파일 위치 확인
fn12(){
echo "12. 데이터파일 위치 확인"
runsql "select file_name from dba_data_files;"
echo "$_rtn"
lnsp
}

# 13. Shell 환경파일
fn13(){
echo "13. Shell 환경파일"
usrsh1=$SHELL
usrsh2=${usrsh1##*/}
if [ $usrsh2 = 'csh' ]; then
        echo "User Shell : $usrsh2"
        echo "$HOME/.cshrc"
        echo ----------------------------------------------
        cat ~/.cshrc
elif [ $usrsh2 = 'ksh' ] || [ $usrsh2 = 'sh' ]; then
        echo "User Shell : $usrsh2"
        echo "$HOME/.profile"
        echo ----------------------------------------------
        cat ~/.profile
elif [ $usrsh2 = 'bash' ]; then
        echo "User Shell : $usrsh2"
        echo "$HOME/.bash_profile"
        echo ----------------------------------------------
        cat ~/.bash_profile
fi
lnsp
}

# 14. Tibero 환경파일(tip 파일)
fn14(){
echo "14. Tibero 환경파일(tip 파일)"
echo "$TB_HOME/config/$TB_SID.tip"
echo ----------------------------------------------
cat $TB_HOME/config/$TB_SID.tip
lnsp
}


conchk;
if [ $_ERR = 'false' ]; then
        echo "Tibero Install Check Date : `date '+%Y/%m/%d %H:%M'`" > $_rfile;
        lnsp >> $_rfile;
        fn1 >> $_rfile;
        fn2 >> $_rfile;
        fn3 >> $_rfile;
        fn4 >> $_rfile;
        fn5 >> $_rfile;
        fn6 >> $_rfile;
        fn7 >> $_rfile;
        fn8 >> $_rfile;
        fn9 >> $_rfile;
        fn10 >> $_rfile;
        fn11 >> $_rfile;
        fn12 >> $_rfile;
        fn13 >> $_rfile;
        fn14 >> $_rfile;
fi