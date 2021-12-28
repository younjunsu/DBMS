#####################################################################################################
#  목  적 : license check shell                                                                     #
#  일  자 : 2012년  05월 27일                                                                       #
#  설  명 : 라이센스 체크 쉘                                                                        #
#  버  전 : 성  명  : 일    자  : 변  경    내  용                                                  #
#  -------  -------   ----------  ----------------------------------------                          #
#  V1.00  : 김정원  : 20120516  : 최초 배포                                                         #
#  V1.01  : 고명국  : 20120522  : Locale C로 고정(prtconf 값이 한글로 나오는 경우가 존재)           #
#  V1.01  : 고명국  : 20120522  : /usr/sbin/psrinfo 명시적으로 사용(path 존재하지 않을 경우대배)    #
#  V1.11  : 김정원  : 20120531  : HP 11.31에 대해여 check 확인                                      #
#  V1.21  : 김진영  : 20130103  : TIBERO 추가, productname 소문자도 인식하게 변경                   #
#  V1.22  : 김권환  : 20131001  : TIBERO NCPU 실행 경로 $TB_HOME/bin/tbinfo 으로 수정               #

if [ $# -ne 1 ];then
echo "Uasge :`basename $0` productname"
echo "EX> `basename $0` JEUS|WEBTOB|TMAX|TIBERO"
exit $BAD_ARGS
fi

PRODUCTNAME=`echo $1 |tr \"a-z\" \"A-Z\" `

export LC_ALL=C
#komyungkok senior reporting for locale

OS=`uname`
#OS="aaa"

PHYSICAL_CNT=""
CORE_CNT=""
THREAD_CNT=""
NCPU=""
#IS_EVERY_OK="OK" #

__tmaxLogo()
{
echo "###################################################################################################"
echo "# Check CPU INFO for license in $OS"
echo "#                                                                                                 #"
echo "#                                                                                        TMAXSOFT #"
echo "###################################################################################################"
}

__ADD()
{
echo ""
echo "###########################################"
echo "# ADDITIONAL INFO $OS"
echo "###########################################"
}

__INFO()
{
echo ""
echo "###########################################"
echo "# CHECK RESULT INFO $OS"
echo "###########################################"
}

__NCPU()
{
echo ""
echo "###########################################"
echo "# NCPU $OS"
echo "###########################################"
}

__EXCEL()
{
echo ""
echo "###########################################"
echo "# EXCEL $OS"
echo "###########################################"
LEN_HW=${#1}
LEN_OS=${#2}
LEN_PRODUCT=${#3}
LEN_VERSION=${#4}
LEN_HOSTNAME=${#5}
LEN_HOSTID=${#6}
LEN_IPADDRESS=${#7}
LEN_NCPU=${#8}



#HOSTNAME은 무조건 8자리로 하자 왜냐햐면 8자리 안되는  hostname이 올때는 정렬이 깨짐
printf "%-${LEN_HW}s %-${LEN_OS}s %-${LEN_PRODUCT}s %-${LEN_VERSION}s %-8s %-${LEN_HOSTID}s %-${LEN_IPADDRESS}s %-${LEN_NCPU}s\n" "H/W" "O/S" "Product" "Version" "HOSTNAME" "HOSTID" "IPADDRESS" "NCPU"
printf "%-${LEN_HW}s %-${LEN_OS}s %-${LEN_PRODUCT}s %-${LEN_VERSION}s %-8s %-${LEN_HOSTID}s %-${LEN_IPADDRESS}s %-${LEN_NCPU}s\n" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"



#printf "%-20s%-30s%-30s%-25s%-10s%-10s%-30s%-30s\n" "H/W" "O/S" "Product" "Version" "HOSTNAME" "HOSTID" "IPADDRESS" "NCPU"
#printf "%-20s%-30s%-30s%-25s%-10s%-10s%-30s%-30s\n" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"

}
__GET_PRO_EDITION()
{
case $1 in
    WEBTOB|webtob)
                #20120531 change
                PRODUCTEDITION=`wsadmin -C "wi" | grep License | awk -F: '{print $2}'|sed 's/^ *//'`
                PRODUCTVERSION=`wsadmin -v | awk  '{print $1,$2,$3,$4,$5,$6}'`
                NCPURUN=ncpu


    ;;
    JEUS|jeus)
                PRODUCTEDITION=`jeusadmin -licenseinfo | grep EDITION | awk -F: '{print $2}'|sed 's/^ *//'`
                PRODUCTVERSION=`jeusadmin -version | grep -v prepend|sed 's/^ *//'`
                NCPURUN=ncpu

    ;;
    TMAX|tmax)
                PRODUCTEDITION=`tmadmin -i $TMAXDIR/license/license.dat | grep Edition |awk -F: '{print $2}' | sed 's/^ *//'`
                PRODUCTVERSION=`tmadmin -v | awk -F, '{print $1}'`
                NCPURUN=$TMAXDIR/license/ncpu

    ;;
    TIBERO|tibero)
                PRODUCTEDITION=`tbboot -l | grep Edition | awk -F: '{print $2}'|sed 's/^ *//'`
                PRODUCTVERSION=`tbboot -v | grep Build `
                NCPURUN=$TB_HOME/bin/tbinfo
                #NCPURUN=~/tbinary/ncpu/linux_64/ncpu

    ;;
    *)
        echo "error"
    ;;

esac
}



__tmaxLogo

linux_check() #@1 : $# @2 : 1bAX5G4B argc @3 : Usage descrption @4 : Example descrption
{
        #echo "============ROW DATA===="
        #cat /proc/cpuinfo
        #uname -a


        __GET_PRO_EDITION $PRODUCTNAME
        PHYSICAL_CNT=`cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l`
        CORE_CNT=`cat /proc/cpuinfo | grep "cpu cores" | tail -1 | cut -d: -f2`
        CORE_ID=`cat /proc/cpuinfo | grep "core id" | sort -u | head -1 | cut -d: -f2`
#       THREAD_CNT=`expr $CORE_CNT / $PHYSICAL_CNT`
        THREAD_CNT=`egrep "^core|^physical" /proc/cpuinfo | awk '{if((NR%2)==0) print $0 "," ; else print $0 }' | awk 'BEGIN {RS=","} {print $1,$2,$3,$4,$5,$6,$7,$8}' | grep ^physical | sort | uniq -c | head -1 | awk '{print $1}'`
        NCPU=`expr $PHYSICAL_CNT \* $CORE_CNT \* $THREAD_CNT`

        #for excel format#
        MODEL=`grep "model name" /proc/cpuinfo | awk -F: '{print $2}' | uniq |awk '{print $1,$2}'`
        OSVERSION=`uname -r`
        #JEUSEDITION=`jeusadmin -licenseinfo | grep EDITION | awk -F: '{print $2}'|sed 's/^ *//'`
        #JEUSVERSION=`jeusadmin -buildversion | grep -v prepend|sed 's/^ *//'`
        HOSTNAME=`hostname`
        HOSTID=`$NCPURUN | grep HOSTID | awk -F: '{print $2}'|sed 's/^ *//'`
        IPADDRESS=`$NCPURUN | grep IPADDRESS | awk -F: '{print $2}'|awk '{print $1}'|sed 's/^ *//'`




}
sun_check() #@1 : $# @2 : 1bAX5G4B argc @3 : Usage descrption @4 : Example descrption
{
        __GET_PRO_EDITION $PRODUCTNAME
        PHYSICAL_CNT=`/usr/sbin/psrinfo -p` #Komyungkok senior reporting (psrinfo -> /usr/sbin/psrinfo)
        CORE_TOT=`kstat -m cpu_info | grep -w core_id | sort -u | wc -l| awk '{print $1}'`
        CORE_CNT=`expr $CORE_TOT / $PHYSICAL_CNT`
        CORE_TOT2=`kstat -m cpu_info | grep -w core_id | wc -l `
        THREAD_CNT=`expr $CORE_TOT2 / $CORE_TOT `
        NCPU=`expr $PHYSICAL_CNT \* $CORE_CNT \* $THREAD_CNT`

        MODEL=`uname -i`
        OSVERSION=`uname -sr`
        HOSTNAME=`hostname`
        HOSTID=`$NCPURUN | grep HOSTID | awk -F: '{print $2}'|sed 's/^ *//'`
        IPADDRESS=`$NCPURUN | grep IPADDRESS | awk -F: '{print $2}'|awk '{print $1}'|sed 's/^ *//'`
}


hp_check() #@1 : $# @2 : 1bAX5G4B argc @3 : Usage descrption @4 : Example descrption
{
        __GET_PRO_EDITION $PRODUCTNAME
        #if hp-ux 11.31
	echo "################ FOR HP 11.31 ##################"

        PHYSICAL_CNT=`machinfo | grep -i processor | grep -v logical | awk '{print $1}'`
        CORE_CNT=`machinfo | grep -i processor | grep  logical | awk -F'(' '{print $2}' | awk '{print $1}'`
        THREAD_INFO=`/usr/sbin/kctune | grep lcpu_attr `
        IS_THREAD_ON=`echo $THREAD_INFO | grep 1 | wc -l`
        if [ $IS_THREAD_ON -eq 1 ];then
        THREAD_CNT=2
        else
        THREAD_CNT=1
        fi
        NCPU=`expr $PHYSICAL_CNT \* $CORE_CNT \* $THREAD_CNT`

        MODEL=`machinfo | grep -i model | awk -F':' '{print $2}'|tr -d ' '`
        OSVERSION=`uname -sr`
        HOSTNAME=`hostname`
        HOSTID=`$NCPURUN | grep HOSTID | awk -F: '{print $2}'|sed 's/^ *//'`
        IPADDRESS=`$NCPURUN | grep IPADDRESS | awk -F: '{print $2}'|awk '{print $1}'|sed 's/^ *//'`
}




aix_check() #@1 : $# @2 : 1bAX5G4B argc @3 : Usage descrption @4 : Example descrption
{
        __GET_PRO_EDITION $PRODUCTNAME
        PHYSICAL_CNT=`lscfg -vp |grep -ip proc |grep PROC|grep WAY | wc -l` # if null@O<v55 @V@=
        CORE_CNT=`lscfg -vp | grep proc | wc -l` # coreD+?nF.

        IMSI_PROC=`lscfg -vp | grep proc | head -1 | awk '{print $1}'` # @S=C GA7N<<<- 08CD(proc0)

        IS_SMT=`lsattr -El $IMSI_PROC | grep smt_enabled| awk '{print $2}'`
        SMT_CNT=`lsattr -El $IMSI_PROC | grep smt_threads| awk '{print $2}'`

        LPAR_ONLINE=`lparstat -i | grep "Online Virtual CPUs" | awk -F':' '{print $2}'`
        LPAR_MAX=`lparstat -i | grep "Maximum Virtual CPUs" | awk -F':' '{print $2}'`

        RATIO=$(echo "scale=2;$LPAR_MAX/$LPAR_ONLINE*100" | bc)

        if [ $IS_SMT = "true" ];then
        THREAD_CNT=$SMT_CNT
        else
        THREAD_CNT=1
        fi

        if [ "$PHYSICAL_CNT" = "" ];then
        PHYSICAL_CNT="I don't know"
        NCPU=`expr $CORE_CNT \* $THREAD_CNT`
        else
        NCPU=`expr $CORE_CNT \* $THREAD_CNT`
        fi

        TOT_CORES=$LPAR_MAX
        CURRENT_CORES=$LPAR_ONLINE


        MODEL=`prtconf | grep "Processor Type" | awk -F: '{print $2}'|sed 's/^ *//'`
        OSVERSION=`uname -rv`
        #PRODUCTEDITION=`jeusadmin -licenseinfo | grep EDITION | awk -F: '{print $2}'|sed 's/^ *//'`
        #PRODUECTVERSION=`jeusadmin -buildversion | grep -v prepend|sed 's/^ *//'`
        HOSTNAME=`hostname`
        HOSTID=`$NCPURUN | grep HOSTID | awk -F: '{print $2}'|sed 's/^ *//'`
        IPADDRESS=`$NCPURUN | grep IPADDRESS | awk -F: '{print $2}'|awk '{print $1}'|sed 's/^ *//'`


        __ADD
        echo  "LART STATUS"
        echo  "POSSIBLE CORES = $TOT_CORES"
        echo  "CURRENT ASSIGNED CORES = $CURRENT_CORES"
        echo  "LPART RATIO = $RATIO($LPAR_MAX(MAX)/$LPAR_ONLINE(ONLINE))"
        echo  "SMT ENABLE = $IS_SMT"
        echo  "SMT THREAD CNT = $SMT_CNT"



}




case $OS in
    Linux)
        linux_check

    ;;
    HP-UX)
        hp_check

    ;;
    IBM)

    ;;
    AIX)
        aix_check

    ;;
    SunOS)
        sun_check
    ;;
    *)
        echo "error"
    ;;

esac

__INFO

if [ "${OS}" = "AIX" ];then
echo  "Physical CPU Count : $PHYSICAL_CNT "
echo  "Core Count : $CORE_CNT "
echo  "Thread Count per Core : $THREAD_CNT "

echo  "======================"
NCPURESULT="$CORE_CNT (cores) * $THREAD_CNT(smt) = $NCPU(NCPU)"
echo "$NCPURESULT"
NCPURESULT2=`echo "$NCPURESULT"|sed 's/^ *//'`

__NCPU
$NCPURUN
__EXCEL "$MODEL" "$OSVERSION" "$PRODUCTEDITION" "$PRODUCTVERSION" "$HOSTNAME" "$HOSTID" "$IPADDRESS" "$NCPURESULT2"

else
echo  "Physical CPU Count : $PHYSICAL_CNT "
echo  "Core Count per Physical CPU : $CORE_CNT "
echo  "Thread Count per Core : $THREAD_CNT "

echo  "======================"
NCPURESULT="$PHYSICAL_CNT(cpu) * $CORE_CNT(cores) * $THREAD_CNT(thread) = $NCPU(NCPU)"
echo "$NCPURESULT"
NCPURESULT2=`echo "$NCPURESULT"|sed 's/^ *//'`

__NCPU
$NCPURUN

__EXCEL "$MODEL" "$OSVERSION" "$PRODUCTEDITION" "$PRODUCTVERSION" "$HOSTNAME" "$HOSTID" "$IPADDRESS" "$NCPURESULT2"

fi
