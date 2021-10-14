
#-----------------------------------------
# Shell name   : Operate Monitor
# Created by   : seojin Heo
# Created date : 2017.09.14
#-----------------------------------------

nodat_cub=`ls ~/cubrid.sh 2>/dev/null `
dat_cub=`ls ~/.cubrid.sh  2>/dev/null`


if [ $dat_cub -z ] 2>/dev/null; then
   if [ $nodat_cub -z ] 2>/dev/null; then
   echo "Need to check environment variables. "
   else
      . ~/cubrid.sh
   fi
else
   . ~/.cubrid.sh
fi


# Pass_Input -----------------------------
pass_input(){
 echo -e " Input your DBA Password : \c"
 stty -echo
 read pass
 stty echo
}

# function -------------------------------
function cut_type_index() {
        local AWK=$1
        BYTE=0
        KBYTE=0
        MBYTE=0
        GBYTE=0
        CUT_TYPE=""

        for CUT_TYPE in $AWK
        do
                BEFORE=0
                AFTER=0
                EXP=0
                TYPE=`echo "$CUT_TYPE" | cut -d'.' -f2 | cut -c 2`
                case "$TYPE" in
                        "B")
                BEFORE=`echo "$CUT_TYPE" | cut -d '.' -f1`
                        AFTER=`echo "$CUT_TYPE" | cut -d '.' -f2 | cut -c 1`
                        EXP=`echo "$BEFORE + $AFTER * 0.1" | bc`
                        BYTE=`echo "$BYTE + $EXP"` ;;
                        "K")
                        BEFORE=`echo "$CUT_TYPE" | cut -d '.' -f1`
                        AFTER=`echo "$CUT_TYPE" | cut -d '.' -f2 | cut -c 1`
                        EXP=`echo "scale=2;$BEFORE + $AFTER * 0.1" | bc`
                        KBYTE=`echo "$KBYTE + $EXP" | bc`
                        BYTE=`echo "scale=2;$KBYTE * 1024" | bc` ;;
                        "M")
                        BEFORE=`echo "$CUT_TYPE" | cut -d '.' -f1`
                        AFTER=`echo "$CUT_TYPE" | cut -d '.' -f2 | cut -c 1`
                        EXP=`echo "$BEFORE + $AFTER * 0.1" | bc`
                        MBYTE=`echo "$MBYTE + $EXP" | bc`
                        BYTE=`echo "$MBYTE * 1024 * 1024" | bc` ;;
                        "G")
                        BEFORE=`echo "$CUT_TYPE" | cut -d '.' -f1`
                        AFTER=`echo "$CUT_TYPE" | cut -d '.' -f2 | cut -c 1`
                        EXP=`echo "$BEFORE + $AFTER * 0.1" | bc`
                        GBYTE=`echo "$GBYTE + $EXP" | bc`
                        BYTE=`echo "$GBYTE * 1024 * 1024 * 1024" | bc` ;;
                esac
                done
                        KBYTE=`echo "scale=2;$BYTE/1024" | bc`
                        TKBYTE=`echo "$TKBYTE + $KBYTE" | bc`
                        echo "TABLE TOTAL INDEX($LIST) : $KBYTE(KB)"
                        rm -rf each_index_info.txt
}

function calculate_index_size() {
        local TABLE_LIST=$1
        local DB_USER=$2
        local isTotal=$3

        if [ "$USER_ID" == "dba" ] || [ "$USER_ID" == "DBA" ]
        then
                DB_USER=$USER_ID
        fi

    # 테이블 인덱스 리스트 생성
        echo ";line on" > index_info.txt
        TKBYTE=0
        for LIST in $TABLE_LIST
        do
                echo "show all indexes capacity of $LIST;" >> index_info.txt

                CNT=1
                #dba계정이 아닌 테이블 전체 인덱스 조회
                if [ "$TABLE_NAME" == "ALL" ] && [ "$gubun" != 0 ]
                then
                        BYTE=0
                        echo ";line on" > each_index_info.txt
                        echo "show all indexes capacity of $LIST;" >> each_index_info.txt
                        EACH_AWK=`csql -u $DB_USER -p "$pass" -i each_index_info.txt $choice_DB@localhost | grep "Total_space" | awk '{print $3}' | cut -c2-9`
                        cut_type_index "$EACH_AWK"
                        CNT=2

                #dba계정 테이블 전체 인덱스 조회
                elif [ "$TABLE_NAME" == "ALL" ] && [ "$gubun" != 1 ]
                then
                        BYTE=0
                        echo ";line on" > each_index_info.txt
                        echo "show all indexes capacity of $LIST;" >> each_index_info.txt
                        EACH_AWK=`csql -u $DB_USER -p "$pass" -i each_index_info.txt $choice_DB@localhost | grep "Total_space" | awk '{print $3}' | cut -c2-9`
                        cut_type_index "$EACH_AWK"
                        CNT=2
                else
                        CNT=1
                fi
        done

        #테이블별 인덱스 space 가져오기
        if [ "$DB_PW" != "" ]
        then
                AWK=`csql -u $DB_USER -p "$pass" -i index_info.txt $choice_DB@localhost | grep "Total_space" | awk '{print $3}' | cut -c2-9`
        else
                AWK=`csql -u $DB_USER -p "$pass" -i index_info.txt $choice_DB@localhost | grep "Total_space" | awk '{print $3}' | cut -c2-9`
        fi
    rm index_info.txt

        if [ "$CNT" == 1 ] && [ "$gubun" == 0 ]
        then
                cut_type_index "$AWK"
        elif [ "$CNT" == 1 ] && [ "$gubun" == 1 ]
        then
                cut_type_index "$AWK"
        fi

        if [ $isTotal = 0 ]
        then
                echo "*************************************************"
                if [ "$DB_USER" == "DBA" ]
                then
                        # system 관리자
                        echo "DB administrator : $DB_USER"
                else
                        # 각 User ID 사용자
                        echo "DB USER명: $COMPARE_USER   TABLE : $TABLE_NAME"
                fi
                echo "--------------------------------------------"
                echo "TOTAL INDEX USE : $TKBYTE(KB)"
                echo "--------------------------------------------"
        fi
        }

function con_index_capa() {
        echo -n "Enter Yes if the total index capacity calculation[Yes(y) Skip(Enter) or No(n)] :"
        read TABLE_NAME
        stty echo

        if [ "$TABLE_NAME" == 'Y' ] ||
       [ "$TABLE_NAME" == 'y' ] ||
       [ "$TABLE_NAME" == 'YES' ] ||
       [ "$TABLE_NAME" == 'Yes' ] ||
       [ "$TABLE_NAME" == 'yes' ] ||
       [ "$TABLE_NAME" == "" ]
        then
                TABLE_NAME="ALL"
        else
                # 테이블 명 입력
                function get_table_name() {
                        echo -n "Enter your table name :"
                        read TABLE_NAME

                        if [ "$TABLE_NAME" == "" ]
                        then
                                echo "  Error Message : Please enter table name"
                                #exit 0
                        else
                                # 테이블명이 있는지 확인
                                TABLE_NAME="$TABLE_NAME"
                                CSQL_CON=""
                                CSQL_CON=`csql -u $USER_ID -p "$pass" -c "select class_name, '|', owner_name from db_class where class_name not in (select vclass_name from db_vclass) and class_name like decode('$TABLE_NAME','ALL','%','$TABLE_NAME') and owner_name like decode(UPPER('$USER_ID'),'DBA','%',UPPER('$USER_ID')) order by owner_name, class_name" -o list.list $choice_DB@localhost 2> index_list.list`
                                CON=`grep "0 rows selected" index_list.list | wc -l`
                                if [ $CON -eq 1 ]
                                then
                                        echo "  Error Message : The missing table name"
                                        get_table_name
                                fi
                        fi
                }
        get_table_name
        fi
}



function calculate_size() {
    local TABLE_LIST=$1
    local DB_USER=$2
    local isTotal=$3

    # 테이블별 통계 스크립트 리스트 생성
    for LIST in $TABLE_LIST
    do
        echo ";info stats $LIST" >> info.txt
    done

    if [ "$USER_ID" == "dba" ] || [ "$USER_ID" == "DBA" ]
    then
        DB_USER=$USER_ID
    fi

    # 테이블별 통계 pages heap size 가져오기
    if [ "$pass" != "" ]
    then
        STAT_INFO=`csql -u $DB_USER -p $pass -i info.txt $choice_DB@localhost | grep "Total pages in class heap:" | awk '{print $6}'`
    else
        STAT_INFO=`csql -u $DB_USER -p "$pass" -i info.txt $choice_DB@localhost | grep "Total pages in class heap:" | awk '{print $6}'`
    fi
    rm info.txt

    KBYTE=0
    for EXP in $STAT_INFO
    do
        # 데이터가 있는 경우에도 pages heap size가 0인 경우가 있어서 1로 처리
        if [ "$EXP" == 0 ]
        then
            EXP=1
        else
            EXP=$EXP
        fi
        # KByte로 계산 Loop = (1page * 16) + KByte
        KBYTE=`echo "$KBYTE + $EXP * 16.0" | bc`
    done
    # 환산(MByte, GByte)
    MBYTE=`echo "scale=2;$KBYTE/1024" | bc`
    GBYTE=`echo "scale=2;$MBYTE/1024" | bc`

    if [ $isTotal = 0 ]
    then
        echo "*************************************************"
        if [ "$DB_USER" == "DBA" ]
        then
            # system 관리자
            echo "DB administrator : $DB_USER"
        else
            # 각 User ID 사용자
            echo "DB USER명: $COMPARE_USER   TABLE : $TABLE_NAME"
        fi
        echo "*************************************************"
            echo "KB : $KBYTE(KB)"
            echo "MB : $MBYTE(MB)"
            echo "GB : $GBYTE(GB)"
        fi
}

function  user_id() {
        USER_ID=""
        echo -e " Input User Name : \c "
        read USER_ID
        stty echo
                if [ "$USER_ID" != "" ]
                then
                        USER_ID="$USER_ID"
                else
                        echo "   You entered an invalied user-name "
                        user_id
                fi
        }

function con_table_capa() {
echo -n "Enter Yes if the total table capacity calculation[Yes(y) Skip(Enter) or No(n)] :"
read TABLE_NAME
stty echo

    if [ "$TABLE_NAME" == 'Y' ] ||
       [ "$TABLE_NAME" == 'y' ] ||
       [ "$TABLE_NAME" == 'YES' ] ||
       [ "$TABLE_NAME" == 'Yes' ] ||
       [ "$TABLE_NAME" == 'yes' ] ||
       [ "$TABLE_NAME" == "" ]
    then
        TABLE_NAME="ALL"
    else
        # 테이블 명 입력
	function get_table_name() {
            echo -n "Enter your table name :"
            read TABLE_NAME

            if [ "$TABLE_NAME" == "" ]
            then
                echo "  Error Message : Please enter table name"
                #exit 0
            else
                # 테이블명이 있는지 확인
                TABLE_NAME="$TABLE_NAME"
                CSQL_CON=""
                CSQL_CON=`csql -u $USER_ID -p $DB_PW -c "select class_name, '|', owner_name from db_class where class_name not in (select vclass_name from db_vclass) and class_name like decode('$TABLE_NAME','ALL','%','$TABLE_NAME') and owner_name like decode(UPPER('$USER_ID'),'DBA','%',UPPER('$USER_ID')) order by owner_name, class_name" -o list.list $DB_NAME@localhost 2> list.list`
                CON=`grep "0 rows selected" list.list | wc -l`
                if [ $CON -eq 1 ]
                then
                    echo "  Error Message : The missing table name"
                    get_table_name
                fi
            fi
        }
    get_table_name
    fi
}


# 1.GENERAL ------------------------------
DB_LIST(){
cnt=1
DB_list=`cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d'`
ha_list=`cat $CUBRID/conf/cubrid_ha.conf | grep -w ha_db_list | cut -d '=' -f2 | sed -e 's/,/ /g'`
for DB_NAME in $DB_list
do
echo "    2-$cnt. $DB_NAME                    "
	DB_stat=`cubrid server status 2>/dev/null |grep -v @ | grep -v +| grep -w "$DB_NAME" | awk '{print $1}'`
	if [ -z $DB_stat ]
	then 
		DB_status="Not Running"
	else
		DB_status="Running"
        for HA_NAME in $ha_list
        do
                if [ "$HA_NAME" == "$DB_NAME" ]
                then
                        DB_mode="HA"
                        break
                else
                        DB_mode="Single"
                fi
        done

#		if [ $DB_stat = 'HA-Server' ]
#		then
#		DB_mode="HA"
#		else
#		DB_mode="Single"
#		fi
	echo "      DB mode       : $DB_mode              "

	fi

#echo "    2-$cnt. $DB_NAME                    "
echo "      DB Status     : $DB_status            "
#echo "      DB mode   : $DB_mode              "
echo
cnt=`expr $cnt + 1`
done

}

BRO_LIST(){
cnt=1
Bro_list=`cat $CUBRID/conf/cubrid_broker.conf | grep % | sed -e 's/[[]//g' | sed -e 's/[]]//g' | sed -e 's/%//g'`
for Bro_Name in $Bro_list
do
echo "    3-$cnt. $Bro_Name                    "
	Bro_stat=`cubrid broker status -b  | grep -i "$Bro_Name" | awk '{print $2}'`
	if [ -z $Bro_stat ]
	then
		Bro_status="Not Running"
	else
		Bro_status="Running"
	fi
echo "      Broker Status : $Bro_status            "
echo
cnt=`expr $cnt + 1`
done
}

Manager_stat(){
Manager=`cubrid manager status | grep running | awk '{print $6}'`
if [ $Manager = 'not' ]
	then 
		Mng_status="Not Running"
	else
		Mng_status="Running"
	fi
echo "     Manager Status : $Mng_status           "
echo
}

service_info(){
#cubrid service status
Master=`cubrid service status | grep "master is" | sed -n '1p' | awk '{print $5}'| sed -e 's/[.]//g'`
if [ $Master = 'not' ]
	then
		Mast_status="Not Running"
	else
		Mast_status="Running"
	fi

#echo "===================================="
#echo " Service Info                       "
#echo "===================================="
echo " 1. Master                          "
echo "      Master status : $Mast_status  "
echo
echo "------------------------------------"
echo
echo " 2. DB                              "
DB_LIST
echo "------------------------------------"
echo
echo " 3. Broker                          "
BRO_LIST
echo "------------------------------------"
echo
echo " 4. Manager                         "
Manager_stat
echo "*************************************"
}


Parameter_info(){
cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
DB_list=`cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d'`
for DB_NAME in $DB_list
do
	DB_stat=`cubrid server status 2>/dev/null |grep -v @| grep -v + | grep -w "$DB_NAME" | awk '{print $1}'`
        if [ -z $DB_stat ]
        then
                DB_status="Not Running"
        else
                DB_status="Running"
        fi
echo " $cnt. $DB_NAME($DB_status)          "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
return=0
imsi=0
until [ "$return" == 1 ]
do
echo -e " Input DB Name : \c                    "
read choice_DB
	if [ "$choice_DB" == 'q' ]
	then
		break
	else
	for DB_NAME in $DB_list
	do
        	if [ "$choice_DB" == $DB_NAME ]
        	then
               		 imsi=1
        	fi
        	if [ $imsi == 1 ]
        	then
			return=1
        	else
                	return=0
        	fi

	done
		if [ $return == 0 ]
		then
		echo "   You entered an invalid db-name"
		fi
	fi
done
clear
if [ "$choice_DB" == 'q' ]
then
	break
else
echo "-------------------------------------"
echo " $choice_DB Parameter Info           "
echo "-------------------------------------"
echo
DB_stat=`cubrid server status 2>/dev/null |grep -v @| grep -v + | grep -w "$choice_DB" | awk '{print $1}'`
if [ -z "$DB_stat" ]
then
	cubrid paramdump -S "$choice_DB" | more -30
else
	cubrid paramdump "$choice_DB"@localhost|more -30
fi
echo
fi
clear
}

version_info(){
cubrid_rel
}

Backup_status(){
cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
echo " 0. ALL                              "
for DB_NAME in `cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d' `
do
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input DB Name : \c                    "
read choice_DB
	if [ "$choice_DB" == 'q' ]
	then
		break
	else
        for DB_NAME in `cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d' `
        do
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
		elif [ "$choice_DB" == 'ALL' ]
		then
			imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
		fi
done
clear
if [ "$choice_DB" == 'q' ]
then
	break
else
if [ "$choice_DB" == 'ALL' ]
then
	backdb=`cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d' `
else
	backdb=$choice_DB
fi
for choice_DB in $backdb
do
echo "-------------------------------------"
echo " $choice_DB Backup Status            "
echo "-------------------------------------"
echo
bkinf_dest=`cat $CUBRID/databases/databases.txt | grep $choice_DB | awk '{print $4}'`

if [ -e $bkinf_dest/"$choice_DB"_bkvinf ]
then
	back_time=`ls -al $bkinf_dest | grep "$choice_DB"_bkvinf | awk '{print $6, $7, $8}'`
	back_dest=`cat $bkinf_dest/"$choice_DB"_bkvinf | awk '{print $3}'`
		if [ -e $back_dest ]
		then
			echo " Backup Location  : $back_dest "	
			echo " Last Backup Time : $back_time "
			echo
			echo " Backup file status : "
			ls -al $back_dest
		else 
			echo " $choice_DB backup file does not exist. "
		fi
echo
echo
else
	echo " $choice_DB backup file does not exist. "
fi
                echo
                echo
                echo " Press Enter to continue. "
                read
                clear

done
fi
}

# 2.DataBase ------------------------------
Database_status(){
cnt=1
DB_list=`cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d'`
ha_list=`cat $CUBRID/conf/cubrid_ha.conf | grep -w ha_db_list | cut -d '=' -f2 | sed -e 's/,/ /g'`
for DB_NAME in $DB_list
do
echo "-------------------------------------"
echo " $cnt. $DB_NAME                      "
echo "-------------------------------------"
        DB_stat=`cubrid server status 2>/dev/null |grep -v @ | grep -v + | grep -w "$DB_NAME" | awk '{print $1}'`
        if [ -z $DB_stat ]
        then
                DB_status="Not Running"
        else
                DB_status="Running"
        for HA_NAME in $ha_list
        do
                if [ "$HA_NAME" == "$DB_NAME" ]
                then
                        DB_mode="HA"
                        break
                else
                        DB_mode="Single"
                fi
        done
#                if [ $DB_stat = 'HA-Server' ]
#                then
#                DB_mode="HA"
#                else
#                DB_mode="Single"
#                fi
        echo "      DB mode       : $DB_mode              "

        fi

echo "      DB Status     : $DB_status            "
echo
cnt=`expr $cnt + 1`
done
}

Database_space(){
cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
echo " 0. ALL                              "
DB_list=`cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d'`
for DB_NAME in $DB_list
do
	DB_stat=`cubrid server status 2>/dev/null |grep -v @| grep -v + | grep -w "$DB_NAME" | awk '{print $1}'`
	if [ -z $DB_stat ] 
	then
		DB_status="Not Running"
	else
		DB_status="Running"
	fi
echo " $cnt. $DB_NAME($DB_status)                "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input DB Name : \c                    "
read choice_DB
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
        for DB_NAME in $DB_list
        do
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
                elif [ "$choice_DB" == 'ALL' ]
                then
                        imsi=1
                fi
                if [ "$imsi" == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
	fi
done
clear
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
if [ "$choice_DB" == 'ALL' ]
then
	for DB_name in `cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d'`
	do
		DB_stat=`cubrid server status 2>/dev/null |grep -v @| grep -v + | grep -w "$DB_name" | awk '{print $1}'`
		echo "-------------------------------------"
		echo " $DB_name Space Info                 "
		echo "-------------------------------------"
	        if [ -z "$DB_stat" ]
        	then
                	cubrid spacedb -s -S  $DB_name
                        echo
                        echo
                        echo " Press Enter to Continue. "
                        read
                        clear
        	else
                	cubrid spacedb -s $DB_name@localhost
                        echo
                        echo
                        echo " Press Enter to Continue. "
                        read
                        clear
        	fi
	done
else
	echo "-------------------------------------"
	echo " $choice_DB Space Info               "
	echo "-------------------------------------"
	echo

	DB_stat=`cubrid server status 2>/dev/null |grep -v @| grep -v + | grep -w "$choice_DB" | awk '{print $1}'`
	if [ -z $DB_stat ] 
	then
		cubrid spacedb -s -S  $choice_DB
	else
		cubrid spacedb -s $choice_DB@localhost
	fi
fi
fi
}

Database_config(){
cat $CUBRID/conf/cubrid.conf | grep -v '#' | sed '/^$/d' | sed 'a\\'
}

# 3.Broker ------------------------------

Broker_info(){
cnt=1
clear
echo "=============================================="
echo " Broker List                                  "
echo "=============================================="
for Bro_NAME in `cat $CUBRID/conf/cubrid_broker.conf | grep % | sed -e 's/[[]//g' | sed -e 's/[]]//g' | sed -e 's/%//g'`
do
Bro_min=`cat $CUBRID/conf/cubrid_broker.conf | sed -n '/'"$Bro_NAME"'/,/%/p' | grep MIN_NUM_APPL_SERVER `
Bro_max=`cat $CUBRID/conf/cubrid_broker.conf | sed -n '/'"$Bro_NAME"'/,/%/p' | grep MAX_NUM_APPL_SERVER `
Bro_port=`cat $CUBRID/conf/cubrid_broker.conf | sed -n '/'"$Bro_NAME"'/,/%/p' | grep BROKER_PORT `
Bro_Log_dir=`cat $CUBRID/conf/cubrid_broker.conf | sed -n '/'"$Bro_NAME"'/,/%/p' | grep -w LOG_DIR `
echo
echo " $cnt. $Bro_NAME                     "
echo
echo " $Bro_port     "
echo " $Bro_min      "
echo " $Bro_max      "
echo " $Bro_Log_dir  "
echo
echo "============================================="
cnt=`expr $cnt + 1`
done

}

Broker_status(){
while true
do
echo "*************************************"
echo " 32 - Broker status                  "
echo "*************************************"
echo
cubrid broker status -f -b
echo
echo
echo "*** Enter 'q' to finish ***"
read answer
if [ "$answer" == 'q' ]
then
	break
else
	clear
fi
done
}

Broker_status_detail(){
cnt=1
down=`cubrid broker status -b | awk '{print $2}' | sed '1,3d' | sed '$d'`
echo "-------------------------------------"
echo " Broker List                         "
echo "-------------------------------------"
if [ -z "$down" ]
then
	echo
	echo " All Broker is not Running.          "
	echo
	echo "-------------------------------------"
	echo
	echo " Press Enter to finish. "
	read
else
echo " 0. ALL                              "
for Bro_NAME in `cubrid broker status -b | awk '{print $2}' | sed '1,3d' | sed '$d'`
do
echo " $cnt. $Bro_NAME                     "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input Broker Name : \c                 "
read choice_Bro
	if [ "$choice_Bro" == 'q' ]
	then
		break
	else
        for Bro_NAME in `cubrid broker status -b | awk '{print $2}' | sed '1,3d' | sed '$d'`
        do
                if [ "$choice_Bro" == $Bro_NAME ]
                then
                         imsi=1
		elif [ "$choice_Bro" == 'ALL' ]
		then
			imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid broker-name"
                fi
	fi
done
clear
if [ "$choice_Bro" == 'q' ]
then
	echo -e
else
while true
do
echo "-------------------------------------"
echo " $choice_Bro Status detail           "
echo "-------------------------------------"
echo
if [ "$choice_Bro" == 'ALL' ]
then
	cubrid broker status -f | more -30
else
	cubrid broker status -f  $choice_Bro | more -30
fi
echo
echo
echo "*** Enter 'q' to finish ***"
read answer
if [ "$answer" == 'q' ]
then
	break
else
	clear
fi
done
fi
fi
}

#Session_count(){
#echo
#}

#session_info(){
#cnt=1
#echo "-------------------------------------"
#echo " Broker List                         "
#echo "-------------------------------------"
#for Bro_NAME in `cubrid broker status -b | awk '{print $2}' | sed '1,3d' | sed '$d'`
#do
#echo " $cnt. $Bro_NAME                     "
#cnt=`expr $cnt + 1`
#done
#echo "-------------------------------------"
#echo
#echo -e " Input Broker Name : \c                 "
#read choice_Bro
#clear
#echo "-------------------------------------"
#echo " $choice_Bro Status detail           "
#echo "-------------------------------------"
#echo
#cubrid broker status -f $choice_Bro | grep BUSY | more -20
#echo

#}

Broker_config(){
cnt=1
echo "-------------------------------------"
echo " Broker List                         "
echo "-------------------------------------"
echo " 0. ALL                              "
for Bro_NAME in `cat $CUBRID/conf/cubrid_broker.conf | grep % | sed -e 's/[[]//g' | sed -e 's/[]]//g' | sed -e 's/%//g'`
do
echo " $cnt. $Bro_NAME                     "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input Broker Name : \c                 "
read choice_Bro
        if [ "$choice_Bro" == 'q' ]
        then
                break
        else

        for Bro_NAME in `cat $CUBRID/conf/cubrid_broker.conf | grep % | sed -e 's/[[]//g' | sed -e 's/[]]//g' | sed -e 's/%//g'`
        do
                if [ "$choice_Bro" == $Bro_NAME ]
                then
                         imsi=1
		elif [ "$choice_Bro" == 'ALL' ]
		then
			imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid broker-name"
                fi
	fi
done

clear
        if [ "$choice_Bro" == 'q' ]
        then
                break
        else

echo "-------------------------------------"
echo " $choice_Bro config Info             "
echo "-------------------------------------"
echo
if [ "$choice_Bro" = 'ALL' ]
then
	cat $CUBRID/conf/cubrid_broker.conf | grep -v '#' | more
else
	cat $CUBRID/conf/cubrid_broker.conf | sed -n '/'"$choice_Bro"'/,/%/p' | sed '$d'
echo
fi
fi
}

# 4.HA ------------------------------
HA_status(){
cnt=1
host_node=`hostname`
Current_state=`cubrid hb status | grep current | awk '{print $6}' | sed -e 's/)//g'`
if [ -z "$Current_state" ]
then
	Current_state="Not Running"
fi
echo "-------------------------------------"
echo " 1. Current node HA Status           "
echo "-------------------------------------"
echo " Current node($host_node) : $Current_state"
for Other in `cubrid hb status | grep priority | awk '{print $2}' | sort`
do
        if [ $Other != $host_node ]
        then
        Other_state=`cubrid hb status | grep priority | grep $Other | awk '{print $6}' | sed -e 's/)//g'`
        echo " Other   node($Other) : $Other_state    "
        fi
done
echo "-------------------------------------"
echo
echo
echo "-------------------------------------"
echo " 2. HA-Server List                   "
echo "-------------------------------------"
for DB_NAME in `cat $CUBRID/conf/cubrid_ha.conf | grep -w ha_db_list | cut -d '=' -f2 | sed -e 's/,/ /g'`
do
Server_state=`cubrid changemode $DB_NAME@localhost 2>/dev/null| awk '{print $9}' | sed -e 's/[.]//g'`
Apply_state=`cubrid hb status | grep $DB_NAME | grep Apply | awk '{print $1}'`
Copy_state=`cubrid hb status | grep $DB_NAME | grep Copy | awk '{print $1}'`
if [ -z "$Server_state" ]
then
	Server_state="Not Running"
fi
if [ -z "$Apply_state" ]
then
	Applylogdb_state="Not Running"
else
	Applylogdb_state="Running"
fi
if [ -z "$Copy_state" ]
then
	Copylogdb_state="Not Running"
else
	Copylogdb_state="Running"
fi
echo "2-$cnt. $DB_NAME                     "
echo
echo "      DB Status     : $Server_state  "
echo "      Applylogdb    : $Applylogdb_state"
echo "      Copylogdb     : $Copylogdb_state"
echo
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo
echo
#echo "-------------------------------------"
#echo " 3. HA Node list                     "
#echo "-------------------------------------"
#echo 
#for Other in `cubrid hb status | grep priority | awk '{print $2}'`
#do
#	if [ $Other != $host_node ]
#	then
#	Other_state=`cubrid hb status | grep priority | grep $Other | awk '{print $6}' | sed -e 's/)//g'`
#	echo " Other node($Other) : $Other_state    "
#	fi
#done

}

HA_apply_info(){

cnt=1
echo "-------------------------------------"
echo " HA-Server List                      "
echo "-------------------------------------"
down=`cubrid server status 2>/dev/null |grep HA | grep -v @ | grep -v + |awk '{print $2}'`
if [ -z "$down" ]
then
echo
echo " All HA-Server is Not Running.       "
echo
echo "-------------------------------------"
echo
else
ha_list=`cat $CUBRID/conf/cubrid_ha.conf | grep -w ha_db_list | cut -d '=' -f2 | sed -e 's/,/ /g'`
for DB_NAME in $ha_list
do
ha_stat=`cubrid server status 2>/dev/null |grep $DB_NAME | grep -v @ | grep -v + `
if [ -z "$ha_stat" ]
then
        echo -e
else
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
fi
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input HA-server Name : \c               "
read choice_DB
	        if [ "$choice_DB" == 'q' ]
        then
                break
        else
        for DB_NAME in $ha_list
        do
                ha_stat=`cubrid server status 2>/dev/null |grep $DB_NAME | grep -v @ | grep -v + `
                if [ -z "$ha_stat" ]
                then
                echo -e
                else
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi
		fi
        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
	fi
done
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
echo
current_host=`hostname`
other_host=`cubrid hb status | grep priority | grep -v $current_host | awk '{print $2}' | sort`
#echo -e " Input Other hostname : \c               "
#read other_host
clear
ha_copy_log_base=`cubrid hb status | grep Applylogdb | grep $choice_DB |sed "s/${choice_DB}@localhost://g" | awk '{print $2}'`
#echo "-------------------------------------"
#echo " $choice_DB HA Apply Info           "
#echo "-------------------------------------"
for host in $other_host
do
clear
imsi=`cubrid hb status | grep priority | grep -w $host | awk '{print $6}'`
if [ $imsi != 'replica)' ]
then
	if [ $imsi != 'unknown)' ]
	then
echo "-------------------------------------"
echo " $choice_DB HA Apply Info($host)     "
echo "-------------------------------------"
	cubrid applyinfo -a -r $host -L $ha_copy_log_base ${choice_DB}
echo
echo " Press Enter to continue..."
read
fi
fi
done
echo
fi
fi
}

Fail_count(){
echo
}

Copylog_info(){
echo
}

HA_warning(){
cnt=1
echo "-------------------------------------"
echo " HA-Server List                      "
echo "-------------------------------------"
down=`cubrid server status 2>/dev/null |grep HA | grep -v @ | grep -v + |awk '{print $2}'`
if [ -z "$down" ]
then
echo
echo " All HA-Server is Not Running.       "
echo
echo "-------------------------------------"
echo
else
ha_list=`cat $CUBRID/conf/cubrid_ha.conf | grep -w ha_db_list | cut -d '=' -f2 | sed -e 's/,/ /g'`
for DB_NAME in $ha_list
do
ha_stat=`cubrid server status 2>/dev/null |grep $DB_NAME | grep -v @ | grep -v + `
if [ -z "$ha_stat" ]
then
        echo -e
else
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
fi
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input HA-server Name    : \c               "
read choice_DB
	if [ "$choice_DB" == 'q' ]
        then
                break
        else
        for DB_NAME in $ha_list
        do
		 ha_stat=`cubrid server status 2>/dev/null |grep $DB_NAME | grep -v @ | grep -v + `
                if [ -z "$ha_stat" ]
                then
                echo -e
                else
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi
		fi
        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
	fi
done
	if [ "$choice_DB" == 'q' ]
        then
                break
        else
Master=`cubrid hb status | grep priority | grep master | awk '{print $2}'`
Slave=`cubrid hb status | grep priority | grep slave | awk '{print $2}' | sort | sed -n '1p'`
#pass_input
imsi=0
return=0
until [ "$return" == 1 ]
do
        pass_input
        if [ -z $pass ]
        then
                correct=`csql -u dba -p '' $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
        else
                correct=`csql -u dba -p "$pass" $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
        fi
        if [ -z "$correct" ]
        then
                imsi=0
        else
                imsi=1
        fi
        if [ $imsi == 1 ]
        then
                return=1
        else
                return=0
        fi
        if [ $return == 0 ]
        then
        echo "   You entered an invalid dba-password"
        echo
        fi
done


clear
if [ "$pass" != "" ]
then 
	pass="-p $pass"
fi
ha_warning_list=`csql -u dba $pass -c "select 'NON_PK', class_name \
from db_class \
where class_type='CLASS' and is_system_class='NO' \
and class_name not in (select distinct class_name from db_index where is_primary_key='YES') \
union all select 'SP', sp_name from db_stored_procedure \
union all select data_type, class_name||' '||attr_name as table_column from db_attribute \
where data_type in ('CLOB','BLOB') \
union all select 'Serial Cache', name from db_serial where cached_num >0 " $choice_DB@$Master`
nonpk_no=`echo "$ha_warning_list" | sed '1,5d' | grep "NON_PK" | wc -l`
sp_no=`echo "$ha_warning_list" | sed '1,5d' |  grep "SP" |  wc -l`
clob_no=`echo "$ha_warning_list" | sed '1,5d' |  grep "CLOB" |  wc -l`
blob_no=`echo "$ha_warning_list" | sed '1,5d' |  grep "BLOB" |  wc -l`
serial_no=`echo "$ha_warning_list" | sed '1,5d' |  grep "Serial" | wc -l`

echo "===================================="
echo "        HA Warning Summary          "
echo "===================================="
echo "    case                  value     "
echo "------------------------------------"
echo "  'NON_PK'                  $nonpk_no"
echo "  'SP'                      $sp_no"
echo "  'CLOB'                    $clob_no"
echo "  'BLBO'                    $blob_no"
echo "  'Serial Cache'            $serial_no"
echo "===================================="
echo
echo
echo "===================================="
echo "           HA Warning List          " 
echo "===================================="
echo "    case                  value     "
echo "------------------------------------"
echo "$ha_warning_list" | sed '1,5d' | sed '$d'
echo "===================================="
echo
echo
echo -e " Do you confirm the comparison of the non_pk tables?(Y/N) : \c "
read answer
if [[ `echo $answer | grep "^[Yy]$\|^[Yy][Ee][Ss]$" | wc -l` -ge 1 ]]
then
clear
non_pk_list=`csql -u dba $pass -c "select 'NON_PK' x, class_name \
from db_class \
where class_type='CLASS' and is_system_class='NO' \
and class_name not in (select distinct class_name from db_index where is_primary_key='YES')" $choice_DB@$Master | grep "NON_PK" | awk '{print $2}'`
non_pk_total=`echo "$non_pk_list" | wc -l`
echo "======================================================================================"
echo "                                   NON PK Table Count                                 "
echo "======================================================================================"
echo " Table name                   Master           Slave            Diff         Progress "
echo "--------------------------------------------------------------------------------------"
cnt=1
for table_name in $non_pk_list
do
        progress=`expr $cnt \* 100 / $non_pk_total`
	table_name=${table_name/\'/}
	table_name=${table_name/\'/}
	Master_count=`csql -u dba $pass -c "select count(*) from $table_name" $choice_DB@$Master 2>&1 | sed -n 6p | awk '{print $1}'`
	Slave_count=`csql -u dba $pass -c "select count(*) from $table_name" $choice_DB@$Slave 2>&1 | sed -n 6p | awk '{print $1}'`
	if [ -z $Slave_count ]
	then
		Slave_count=0
	fi
	TDIFF=`expr $Master_count - $Slave_count 2>/dev/null`
	printf "%-20s %15d %15d %15d %15d" $table_name $Master_count $Slave_count $TDIFF $progress
	echo "%"
cnt=`expr $cnt + 1`
done
echo "======================================================================================"
fi
fi
fi
}


HA_config(){
cat $CUBRID/conf/cubrid_ha.conf  | grep -v '#' | sed '/^$/d' | sed 'a\\'
}

# 5.Query ------------------------------
Query_statistics(){
cnt=1
echo "-------------------------------------"
echo " Broker List                         "
echo "-------------------------------------"
for Bro_NAME in `cat $CUBRID/conf/cubrid_broker.conf | grep % | sed -e 's/[[]//g' | sed -e 's/[]]//g' | sed -e 's/%//g'`
do
echo " $cnt. $Bro_NAME                     "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
cub_rel=`cubrid_rel |awk '{print $2}'|sed -n '2p'`
if [ "$cub_rel" == "2008" ]; then
        cub_rel=`cubrid_rel`
        cub_rel_result=`echo $cub_rel |awk '{print $4}' |sed  's/(/ /g' | sed 's/)/ /g' | awk -F '[.]' '{print $1 $2 $3}'`
else
        cub_rel=`cubrid_rel`
        cub_rel_result=`echo $cub_rel |awk '{print $3}' |sed  's/(/ /g' | sed 's/)/ /g' | awk -F '[.]' '{print $1 $2 $3}'`
fi
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input Broker Name : \c                 "
read choice_Bro
        if [ "$choice_Bro" == 'q' ]
        then
                break
        else
        for Bro_NAME in `cat $CUBRID/conf/cubrid_broker.conf | grep % | sed -e 's/[[]//g' | sed -e 's/[]]//g' | sed -e 's/%//g'`
        do
                if [ $choice_Bro == $Bro_NAME ]
                then
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid broker-name"
                fi
	fi
done
        if [ "$choice_Bro" == 'q' ]
        then
                echo -e
        else

choice_Bro=`echo $choice_Bro | tr '[A-Z]' '[a-z]'`

if [ $cub_rel_result -ge 844 ]
then
	echo -e " Input the start time(yy-mm-dd hh:mm:ss) : \c              "
	read from_time
	echo -e " Input the finish time(yy-mm-dd hh:mm:ss) : \c             "
	read to_time
else
	echo -e " Input the start time(mm/dd hh:mm:ss) : \c              "
        read from_time
        echo -e " Input the finish time(mm/dd hh:mm:ss) : \c             "
        read to_time
fi
clear
default_dir="log/broker/sql_log"
log_dir=`cat $CUBRID/conf/cubrid_broker.conf |grep -i -A15 $choice_Bro |grep LOG_DIR |grep -v '#'|grep -v 'error'|awk '{print $2}'|sed -s 's/=/ /g'`
result_dir=$CUBRID/tmp/cub_maintenance/scripts_check/operator
mkdir -p $result_dir/`date +%Y%m%d` 2>/dev/null
cd $result_dir/`date +%Y%m%d`
if [ $log_dir == $default_dir ]
then
	if [ -z $from_time ]
	then
		broker_log_top $CUBRID/log/broker/sql_log/$choice_Bro* 1>/dev/null
	else
		broker_log_top -F "$from_time" -T "$to_time" $CUBRID/log/broker/sql_log/$choice_Bro* 1>/dev/null
	fi
else
	if [ -z $from_time ]
	then
		broker_log_top $log_dir/$choice_Bro* 1>/dev/null
	else
		broker_log_top -F "$from_time.000" -T "$to_time.000" $log_dir/$choice_Bro* 1>/dev/null
	fi
fi
echo
echo
echo "The location of the logfile is $result_dir/`date +%Y%m%d`. "
echo "If you want to check the file, please return to the back and Press 52, 53"
echo
echo " Press Enter to continue..."
read
fi
}

Query_static(){
vi $CUBRID/tmp/cub_maintenance/scripts_check/operator/`date +%Y%m%d`/log_top.res
}

Query_detail(){
vi $CUBRID/tmp/cub_maintenance/scripts_check/operator/`date +%Y%m%d`/log_top.q
}

Data_Hit_Ratio(){
cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
down=`cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
if [ -z "$down" ]
then
echo
echo " All DB-Server is Not Running.       "
echo
echo "-------------------------------------"
echo
else
for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
do
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input DB Name : \c                    "
read choice_DB
	if [ "$choice_DB" == 'q' ]
        then
                break
        else
       for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
        do
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
	fi
done
echo
clear
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
echo "---------------------------------------"
echo " $choice_DB Data page buffer Hit Ratio"
echo "---------------------------------------"
echo
cubrid statdump $choice_DB@localhost | grep hit_ratio
fi
fi
}

# 6.Transaction / Lock ------------------------------
Transaction_status(){
cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
down=`cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
if [ -z "$down" ]
then
echo
echo " All DB-Server is Not Running.       "
echo
echo "-------------------------------------"
echo
else
for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
do
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input DB Name : \c                    "
read choice_DB
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
        for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
        do
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
	fi
done
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
	pass_input
	if [ -z $pass ]
	then
		correct=`csql -u dba -p '' $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
	else
		correct=`csql -u dba -p $pass $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
	fi
	if [ -z "$correct" ]
	then
		imsi=0
	else
		imsi=1
	fi
	if [ $imsi == 1 ]
	then
		return=1
	else
		return=0
	fi
	if [ $return == 0 ]
	then
	echo "   You entered an invalid dba-password"
	echo
	fi
done
clear
echo "-------------------------------------"
echo " $choice_DB Transaction Status       "
echo "-------------------------------------"
echo
        if [ -z "$pass" ]
        then
	tran=`cubrid killtran $choice_DB@localhost -q 2>/dev/null | awk '{print $1}'`
		if [ -z "$tran" ]
		then
			cubrid killtran $choice_DB@localhost | more -30
		else
	 	       cubrid killtran -q $choice_DB@localhost | more -30
		fi
        else
	tran=`cubrid killtran $choice_DB@localhost -q -p $pass 2>/dev/null | awk '{print $1}'`
		if [ -z "$tran" ]
		then
			cubrid killtran -p $pass $choice_DB@localhost | more -30
		else
	        	cubrid killtran -q -p $pass $choice_DB@localhost | more -30
		fi
        fi
echo
echo -e " Will you kill the transaction?(Y/N) : \c "
read answer
if [[ `echo $answer | grep "^[Yy]$\|^[Yy][Ee][Ss]$" | wc -l` -ge 1 ]]
then
        echo -e " Input Transaction ID : \c            "
        read Tran_ID
if [ -z $pass ]
        then
        cubrid killtran  -i $Tran_ID $choice_DB@localhost
        else
        cubrid killtran -p $pass -i $Tran_ID $choice_DB@localhost
        fi
else
        echo
fi
fi
fi
}

Kill_Transaction(){
cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
do
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo
echo -e " Input DB Name : \c                    "
read choice_DB
echo
pass_input
echo -e " Input Transaction ID : \c            "
read Tran_ID
        if [ -z $pass ]
        then
	cubrid killtran  -i $Tran_ID $choice_DB@localhost
	else
	cubrid killtran -p $pass -i $Tran_ID $choice_DB@localhost
	fi
}

Lock_status(){
cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
down=`cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
if [ -z "$down" ]
then
echo
echo " All DB-Server is Not Running.       "
echo
echo "-------------------------------------"
echo
else
for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
do
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input DB Name : \c                    "
read choice_DB
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
        for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
        do
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
	fi
done
echo
clear
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
echo "-------------------------------------"
echo " $choice_DB Lock Status              "
echo "-------------------------------------"
echo
cubrid lockdb $choice_DB@localhost | more -30
fi
fi
}

# 7.Other ------------------------------
CSQL(){
cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
down=`cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
if [ -z "$down" ]
then
echo
echo " All DB-Server is Not Running.       "
echo
echo "-------------------------------------"
echo
        echo " Press Enter to finish. "
else
for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
do
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input DB Name : \c                    "
read choice_DB
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
        for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
        do
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
	fi
done
#pass_input
        if [ "$choice_DB" == 'q' ]
        then
                echo -e
        else
imsi=0
return=0
until [ "$return" == 1 ]
do
        pass_input
        if [ -z $pass ]
        then
                correct=`csql -u dba -p '' $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
        else
                correct=`csql -u dba -p $pass $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
        fi
        if [ -z "$correct" ]
        then
                imsi=0
        else
                imsi=1
        fi
        if [ $imsi == 1 ]
        then
                return=1
        else
                return=0
        fi
        if [ $return == 0 ]
        then
        echo "   You entered an invalid dba-password"
        echo
        fi
done
clear
if [ "$pass" != "" ]
then pass="-p $pass"
fi
csql -u dba $pass $choice_DB@localhost
fi
fi
}

Volume_location(){
cnt=1
DB_list=`cat $CUBRID/databases/databases.txt | awk '{print $1}' | sed '/#/d'`
for DB_NAME in $DB_list
do
echo "-------------------------------------"
echo " $cnt. $DB_NAME                      "
echo "-------------------------------------"
        Data_Location=`cat $CUBRID/databases/databases.txt | sed '/#/d' | grep $DB_NAME | awk '{print $2}'`
	Log_Location=`cat $CUBRID/databases/databases.txt | sed '/#/d' | grep $DB_NAME | awk '{print $4}'`
	Lob_Location=`cat $CUBRID/databases/databases.txt | sed '/#/d' | grep $DB_NAME | awk '{print $5}'`
echo
echo " DataVolume_Location  :  $Data_Location       "
echo " LogVolume_Location   :  $Log_Location       "
echo " Lobfile_Location     :  $Lob_Location       "
echo
cnt=`expr $cnt + 1`
done


}

Manager_Status(){
Manager=`cubrid manager status | awk '{print $6}' | sed '1d'`
Manager_port=`cat $CUBRID/conf/cm.conf | grep  "cm_port=" | sed -e 's/cm_port=//g'`
if [ -z $Manager_port ]
then
	Manager_port=`cat $CUBRID/conf/cm.conf | grep  "cm_port " | sed -e 's/cm_port //g'`
fi
echo
if [ $Manager = 'not' ]
        then
                Mng_status="Not Running"
        else
                Mng_status="Running"
        fi

echo " Manager Status     :    $Mng_status"
echo " Manager Port       :    $Manager_port"
}

System_Info(){
Host=`hostname`
OS_version=`cat /etc/redhat-release`
Kernal_version=`uname -a | awk '{print $3}'`
CPU=`grep -c processor /proc/cpuinfo`
Socket=`lscpu | grep -w "Socket(s):" | awk '{print $2}'`
MEMORY=`cat /proc/meminfo | grep MemTotal | awk '{print $2, $3}'`
echo "-------------------------------------"
echo " System Info                         "
echo "-------------------------------------"
echo " 1. Hostname       : $Host           "
echo " 2. Linux Version  : $OS_version     "
echo " 3. Kernal_version : $Kernal_version "
echo " 4. CPU core       : $CPU            "
echo " 5. CPU Socket     : $Socket         "
echo " 6. Memory Total   : $MEMORY         "
echo "-------------------------------------"
}

User_Info(){

cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
down=`cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
if [ -z "$down" ]
then
echo
echo " All DB-Server is Not Running.       "
echo
echo "-------------------------------------"
echo
else
for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
do
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input DB Name : \c                    "
read choice_DB
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
        for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
        do
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
	fi
done

        if [ "$choice_DB" == 'q' ]
        then
                break
        else
imsi=0
return=0
until [ "$return" == 1 ]
do
        pass_input
        if [ -z $pass ]
        then
                correct=`csql -u dba -p '' $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
        else
                correct=`csql -u dba -p $pass $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
        fi
        if [ -z "$correct" ]
        then
                imsi=0
        else
                imsi=1
        fi
        if [ $imsi == 1 ]
        then
                return=1
        else
                return=0
        fi
        if [ $return == 0 ]
        then
        echo "   You entered an invalid dba-password"
        echo
        fi
done

#pass_input
clear
echo
cub_rel=`cubrid_rel | awk '{print $2}' | sed -n '2p'`
if [ $cub_rel = 2008 ]; then
cub_rel=`cubrid_rel`
cub_rel_result=`echo $cub_rel | awk '{print $4}' | sed 's/(/ /g' | sed 's/)/ /g' | awk -F '[.]' '{print $1,$2,$3}' | sed -e 's/ //g'`
else
cub_rel=`cubrid_rel`
cub_rel_result=`echo $cub_rel | awk '{print $3}' | sed 's/(/ /g' | sed 's/)/ /g' | awk -F '[.]' '{print $1,$2,$3}' | sed -e 's/ //g'`
fi
if [ -s $choice_DB@localhost_schema ]
then
	echo
else
	if [ $cub_rel_result -gt 920 ]
	then
		if [ -z $pass ]
		then
        	cubrid unloaddb -u dba -s $choice_DB@localhost
		else
		cubrid unloaddb -u dba -p $pass -s $choice_DB@localhost
		fi
	else
		cubrid unloaddb -s $choice_DB@localhost
	fi
fi

cnt=1
user_list=`cat $choice_DB@localhost_schema | grep add_user | cut -d '(' -f2 | cut -d ',' -f1 | uniq`
member_list=`cat $choice_DB@localhost_schema | grep add_member | cut -d '(' -f2 | cut -d ')' -f1 | uniq`
echo "==================================="
echo "             User List             "
echo "==================================="
echo "    User name        Group name    "
echo "-----------------------------------"
echo " DBA              "
echo " Public           "
for user in $user_list
do
        user=${user/\'/}
        user=${user/\'/}
        group_name=`cat $choice_DB@localhost_schema | grep -w add_member | grep -w $user | awk '{print $4}' | cut -d '_' -f2 | cut -d ']' -f1 | paste -sd " "`
        if [ -z "$group_name" ]
        then
                group_name=" "
        fi
        printf " "
        printf "%-15s" $user
        printf ":  "
        if [ $user != 'DBA' ]
        then
                if [ $user != "Public" ]
                then
                        printf "PUBLIC "
                fi
        fi
        printf "$group_name"
        printf "\n"
cnt=`expr $cnt + 1`
done
echo "==================================="
fi
fi
}

table_size_info(){
cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
down=`cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
if [ -z "$down" ]
then
echo
echo " All DB-Server is Not Running.       "
echo
echo "-------------------------------------"
echo
else
for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
do
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input DB Name : \c                    "
read choice_DB
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
        for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
        do
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
        fi
done

        if [ "$choice_DB" == 'q' ]
        then
                break
        else

imsi=0
return=0
until [ "$return" == 1 ]
do
	user_id
         echo -e " Input your User Password : \c"
	 stty -echo
	 read pass
	 stty echo

        if [ -z $pass ]
        then
                correct=`csql -u $USER_ID -p '' $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
        else
                correct=`csql -u $USER_ID -p $pass $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
        fi
        if [ -z "$correct" ]
        then
                imsi=0
        else
                imsi=1
        fi
        if [ $imsi == 1 ]
        then
                return=1
        else
                return=0
        fi
        if [ $return == 0 ]
        then
        echo "   You entered an invalid dba-password"
        echo
        fi
done
fi
fi

########### Shell Program Start ############
FIND_LIST=`find -name "list.list" -type f | wc -l`
if [ $FIND_LIST -gt 0 ]
then
    rm -rf list.list
fi

clear
#con_db_name
#con_userid_pw
con_table_capa
#rm -rf list.list

#After get table list db connect
# 테이블 리스트 list.list 생성
CSQL_CON=""
if [ "$pass" != "" ]
then
    CSQL_CON=`csql -u $USER_ID -p $pass -c "select class_name, '|', owner_name from db_class where class_name not in (select vclass_name from db_vclass) and class_name like decode('$TABLE_NAME','ALL','%','$TABLE_NAME') and owner_name like decode(UPPER('$USER_ID'),'DBA','%',UPPER('$USER_ID')) order by owner_name, class_name" -o list.list $choice_DB@localhost 2> list.list`
else
    CSQL_CON=`csql -u $USER_ID -p "$pass" -c "select class_name, '|', owner_name from db_class where class_name not in (select vclass_name from db_vclass) and class_name like decode('$TABLE_NAME','ALL','%','$TABLE_NAME') and owner_name like decode(UPPER('$USER_ID'),'DBA','%',UPPER('$USER_ID')) order by owner_name, class_name" -o list.list $choice_DB@localhost 2> list.list`
fi

#Checking for errors
CON=`grep "ERROR:" list.list | wc -l`
CON_ROW=`grep -w "0 rows selected." list.list | wc -l`
if [ $CON -eq 1 ] || [ $CON_ROW -eq 1 ]
then
  #echo `grep "ERROR:" list.list`
  echo "  Table($TABLE_NAME)" `grep "ERROR:" list.list` `grep "0 rows selected." list.list`
  exit 0
fi

# list.list를 가공하여 재생성
sed -i '1,5d' list.list
sed -i '$d' list.list
sed -i 's/'\''//g' list.list
sed -i 's/ //g' list.list

MAP=`cat list.list`

COMPARE_USER=""
TOTAL_LIST=""
TBL_LIST=""
INDEX=0

# 한줄씩 읽어서 사용자ID, 테이블명 분리
clear
for AT in $MAP
do
        USER=`echo $AT | cut -d'|' -f2`
        TABLE=`echo $AT | cut -d'|' -f1`

        BEFORE_USER="$USER"
        if [ $INDEX = 0 ]
        then
            COMPARE_USER="$USER"
            INDEX=1
        fi

        if [ $COMPARE_USER != "$USER" ]
        then
             # User ID별 용량 사이즈 계산함수 호출
             calculate_size "$TBL_LIST" "$COMPARE_USER" 0
             BEFORE_USER="$USER"
             INDEX=0
             TBL_LIST=""
        fi
        # User ID별 테이블 리스트
        TBL_LIST="$TBL_LIST $TABLE"
done

# Full list of last user's table list(statistics)
calculate_size "$TBL_LIST" "$COMPARE_USER" 0

echo "*************************************************"
############ Shall Program END ############



}

index_size_info(){
cnt=1
echo "-------------------------------------"
echo " DB List                             "
echo "-------------------------------------"
down=`cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
if [ -z "$down" ]
then
echo
echo " All DB-Server is Not Running.       "
echo
echo "-------------------------------------"
echo
else
for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
do
echo " $cnt. $DB_NAME                      "
cnt=`expr $cnt + 1`
done
echo "-------------------------------------"
echo " *** Enter 'q' to Finish. *** "
echo
echo
imsi=0
return=0
until [ "$return" == 1 ]
do
echo -e " Input DB Name : \c                    "
read choice_DB
        if [ "$choice_DB" == 'q' ]
        then
                break
        else
        for DB_NAME in `cubrid server status 2>/dev/null |grep -v @ | grep -v +  | awk '{print $2}'`
        do
                if [ "$choice_DB" == $DB_NAME ]
                then
                         imsi=1
                fi
                if [ $imsi == 1 ]
                then
                        return=1
                else
                        return=0
                fi

        done
                if [ $return == 0 ]
                then
                echo "   You entered an invalid db-name"
                fi
        fi
done

        if [ "$choice_DB" == 'q' ]
        then
                break
        else

imsi=0
return=0
until [ "$return" == 1 ]
do
         user_id
         echo -e " Input your User Password : \c"
         stty -echo
         read pass
         stty echo

        if [ -z $pass ]
        then
                correct=`csql -u $USER_ID -p '' $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
        else
                correct=`csql -u $USER_ID -p $pass $choice_DB@localhost -c 'select 1 from db_root' 2>/dev/null`
        fi
        if [ -z "$correct" ]
        then
                imsi=0
        else
                imsi=1
        fi
        if [ $imsi == 1 ]
        then
                return=1
        else
                return=0
        fi
        if [ $return == 0 ]
        then
        echo "   You entered an invalid dba-password"
        echo
        fi
done
fi
fi


########### Shell Program Start ############
FIND_LIST=`find -name "index_list.list" -type f | wc -l`
if [ $FIND_LIST -gt 0 ]
then
        rm -rf index_list.list
fi

clear
con_index_capa

#After get table list db connect
# 인덱스 리스트 index_list.list 생성
CSQL_CON=""
if [ "$pass" != "" ]
then
        CSQL_CON=`csql -u $USER_ID -p "$pass" -c "select a.class_name, '|', a.owner_name from db_class a inner join (select distinct class_name from db_index where class_name not like 'db%' and class_name not like '_db%' and class_name not like '_cub%') b on a.class_name = b.class_name where a.class_name not in ('db_authorizations', 'db_trigger') and a.class_name not in (select vclass_name from db_vclass) and a.class_name like decode('$TABLE_NAME','ALL','%','$TABLE_NAME') and a.owner_name like decode(UPPER('$USER_ID'),'DBA','%',UPPER('$USER_ID')) order by a.owner_name, a.class_name" -o index_list.list $choice_DB@localhost 2> index_list.list`
else
        CSQL_CON=`csql -u $USER_ID -p "$pass" -c "select a.class_name, '|', a.owner_name from db_class a inner join (select distinct class_name from db_index where class_name not like 'db%' and class_name not like '_db%' and class_name not like '_cub%') b on a.class_name = b.class_name where a.class_name not in ('db_authorizations', 'db_trigger') and a.class_name not in (select vclass_name from db_vclass) and a.class_name like decode('$TABLE_NAME','ALL','%','$TABLE_NAME') and a.owner_name like decode(UPPER('$USER_ID'),'DBA','%',UPPER('$USER_ID')) order by a.owner_name, a.class_name" -o index_list.list $choice_DB@localhost 2> index_list.list`
fi

#Checking for errors
CON=`grep "ERROR:" index_list.list | wc -l`
CON_ROW_VAL=`grep "0 rows selected." index_list.list | awk '{print $1}'`
if [ $CON -eq 1 ] || [ "$CON_ROW_VAL" == "0" ]
then
        echo "  Table($TABLE_NAME)" `grep "ERROR:" index_list.list` `grep "0 rows selected." index_list.list`
        read
	clear
	index_size_info
fi

#
if [ "$USER_ID" == "dba" ]
then
        #echo "user_id = $USER_ID"
        gubun=0
else
        gubun=1
fi

# index_list.list를 가공하여 재생성
sed -i '1,5d' index_list.list
sed -i '$d' index_list.list
sed -i 's/'\''//g' index_list.list
sed -i 's/ //g' index_list.list

MAP=`cat index_list.list`

COMPARE_USER=""
TOTAL_LIST=""
TBL_LIST=""
INDEX=0

# 한줄씩 읽어서 사용자ID, 테이블명 분리
clear
for AT in $MAP
do
        USER=`echo $AT | cut -d'|' -f2`
        TABLE=`echo $AT | cut -d'|' -f1`

        BEFORE_USER="$USER"
        if [ $INDEX = 0 ]
        then
                COMPARE_USER="$USER"
                INDEX=1
        fi

        if [ $COMPARE_USER != "$USER" ]
        then
                # User ID별 용량 사이즈 계산함수 호출
                calculate_index_size "$TBL_LIST" "$COMPARE_USER" 0
                BEFORE_USER="$USER"
                INDEX=0
                TBL_LIST=""
        fi
        # User ID별 테이블 리스트
        TBL_LIST="$TBL_LIST $TABLE"
done

# Full list of last user's table list(statistics)
calculate_index_size "$TBL_LIST" "$COMPARE_USER" 0

rm -rf index_list.list
rm -rf list.list
echo "*************************************************"
############ Shall Program END ############

}

# 8.Help ------------------------------
Restart(){
echo
}

Add_volume(){
echo
}

while true
do
clear
echo " ******************************************************************** "
echo "  CUBRID Operating Moniter                                            "
echo " ******************************************************************** "
echo "  1.GENERAL                        *  2.DataBase                      "
echo " ******************************************************************** "
echo "  11 - Service Status              *  21 - Database Status            "
echo "  12 - Parameter Info              *  22 - Database Space             "
echo "  13 - Version Info                *  23 - Database config            "
echo "  14 - Backup Status               *                                  "
echo " ******************************************************************** "
echo "  3.Broker                         *  4.HA                            "
echo " ******************************************************************** "
echo "  31 - Broker Info                 *  41 - HA Status                  " 
echo "  32 - Broker status               *  42 - HA apply info              "
echo "  33 - Broker status(detail)       *  43 - HA Warning                 "
echo "  34 - Broker config               *  44 - HA config                  "
echo " ******************************************************************** "
echo "  5.Query                          *  6.Transaction / Lock            "
echo " ******************************************************************** "
echo "  51 - Broker log top              *  61 - Transaction status         "
echo "  52 - Query_static                *  62 - Lock status                "
echo "  53 - Query_static_detail         *                                  "
echo "  54 - Data page Buffer Hit Ratio  *                                  "
echo " ******************************************************************** "
echo "  7.OTHER                          *  8.HELP                          "
echo " ******************************************************************** "
echo "  71 - CSQL                        *  81 - Restart Help               "
echo "  72 - Volume location Info        *  82 - Add Volume Help            "
echo "  73 - Manager Status              *  83 - HA Warning Help            "
echo "  74 - System Info                 *                                  "
echo "  75 - User Info                   *                                  "
echo "  76 - Table Size Info             *                                  "
echo "  77 - Index Size Info             *                                  "
echo "  00 - Exit                        *                                  "
echo " ******************************************************************** "
echo
echo -e "Input the Number : \c"
read number
case $number in

# 1.GENERAL ------------------------------------
11)
clear
echo "*************************************"
echo " 11 - Service Status                 "
echo "*************************************"
echo
service_info
echo
echo " Press Enter to continue..."
read 
;;

12)
clear
while true
do
echo "*************************************"
echo " 12 - Parameter Info                 "
echo "*************************************"
echo
Parameter_info
echo
echo
echo " ************************************"
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo " ************************************"
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
#echo " Press Enter to continue..."
#read
;;
 
13)
clear
echo "*************************************"
echo " 13 - Version Info                   "
echo "*************************************"
echo
version_info
echo
echo " Press Enter to continue..."
read
;;

14)
clear
while true
do
echo "*************************************"
echo " 14 - Backup Status                  "
echo "*************************************"
echo
Backup_status
echo
echo
echo " ************************************"
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo " ************************************"
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
#echo " Press Enter to continue..."
#read
;;

# 2.DataBase -----------------------------------

21)
clear
echo "*************************************"
echo " 21 - Database Status                "
echo "*************************************"
echo
Database_status | more
echo
echo " Press Enter to continue..."
read
;;

22)
clear
while true
do
echo "*************************************"
echo " 22 - Database Space                 "
echo "*************************************"
echo
Database_space
echo
echo
echo " ************************************"
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo " ************************************"
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
;;

23)
clear
echo "*************************************"
echo " 23 - Database config                "
echo "*************************************"
echo
Database_config
echo
echo " Press Enter to continue..."
read
;;

# 3.Broker -------------------------------------

31)
clear
echo "*************************************"
echo " 31 - Broker Info                    "
echo "*************************************"
echo
Broker_info
echo
echo " Press Enter to continue..."
read
;;

32)
clear
Broker_status
echo
;;

33)
clear
echo "*************************************"
echo " 33 - Broker status(detail)          "
echo "*************************************"
echo
Broker_status_detail
echo
;;


34)
clear
while true
do
Broker_config
echo
echo
echo " ************************************"
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo " ************************************"
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
#echo " Press Enter to continue..."
#read
;;

# 4.HA -----------------------------------------


41)
clear
echo "*************************************"
echo " 41 - HA Status                      "
echo "*************************************"
echo
HA_status | more
echo
echo " Press Enter to continue..."
read
;;

42)
clear
while true
do
echo "*************************************"
echo " 42 - HA Apply info                  "
echo "*************************************"
echo
HA_apply_info
echo
echo
echo " ************************************"
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo " ************************************"
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
;;


43)
clear
while true
do
echo "*************************************"
echo " 43 - HA Warning                     "
echo "*************************************"
echo
HA_warning
echo
echo
echo " ************************************"
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo " ************************************"
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
;;
#echo " Press Enter to continue..."
#read


44)
clear
echo "*************************************"
echo " 44 - HA config                      "
echo "*************************************"
echo
HA_config
echo
echo " Press Enter to continue..."
read
;;

# 5.Query --------------------------------------

51)
clear
echo "*************************************"
echo " 51 - Query statistics               "
echo "*************************************"
echo
Query_statistics
;;

52)
clear
echo "*************************************"
echo " 52 - Query_static                   "
echo "*************************************"
echo
Query_static
echo
echo " Press Enter to continue..."
#read
;;


53)
clear
echo "*************************************"
echo " 53 - Query_static_detail            "
echo "*************************************"
echo
Query_detail
echo
echo " Press Enter to continue..."
#read
;;

54)
clear
while true
do
echo "*************************************"
echo " 54 - Data page Buffer Hit Ratio     "
echo "*************************************"
echo
Data_Hit_Ratio
echo
echo
echo " ************************************"
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo " ************************************"
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
;;
#echo " Press Enter to continue..."
#read

# 6.Transaction / Lock -------------------------

61)
clear
while true
do
echo "*************************************"
echo " 61 - Transaction status             "
echo "*************************************"
echo
Transaction_status
echo
echo
echo " ************************************"
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo " ************************************"
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
#echo " Press Enter to continue..."
#read
;;

#62)
#clear
#echo "*************************************"
#echo " 62 - Kill Transaction               "
#echo "*************************************"
#echo
#Kill_Transaction
#echo
#echo " Press Enter to continue..."
#read
#;;

62)
clear
while true
do
echo "*************************************"
echo " 62 - Lock status                    "
echo "*************************************"
echo
Lock_status
echo
echo
echo " ************************************"
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo " ************************************"
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
#echo " Press Enter to continue..."
#read
;;


# 7.OTHER --------------------------------------

71)
clear
echo "*************************************"
echo " 71 - CSQL                           "
echo "*************************************"
echo
CSQL
#echo " Press Enter to continue..."
;;

72)
clear
echo "*************************************"
echo " 72 - Volume_location                "
echo "*************************************"
echo
Volume_location | more
echo
echo " Press Enter to continue..."
read
;;


73)
clear
echo "*************************************"
echo " 73 - Manager Status                 "
echo "*************************************"
echo
Manager_Status
echo
echo " Press Enter to continue..."
read
;;


74)
clear
echo "*************************************"
echo " 74 - System Info                    "
echo "*************************************"
echo
System_Info
echo
echo " Press Enter to continue..."
read
;;

75)
clear
while true
do
echo "*************************************"
echo " 75 - User Info                    "
echo "*************************************"
echo
User_Info
echo
echo
echo " ************************************"
echo " Press 'q' to Finish."
echo " Press Enter to continue."
echo " ************************************"
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done
#echo " Press Enter to continue..."
#read
;;

76)
clear
while true
do
table_size_info
echo
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done

;;

77)
clear
while true
do
echo "========================================================="
echo "                   * Warning Message *                   "
echo "Index size info is running only in 9.3 or higher version "
echo "========================================================="
echo
index_size_info
echo
read answer
if [ "$answer" == 'q' ]
then
        break
else
        clear
fi
done

;;

00)
clear
break
;;


# 8.HELP ---------------------------------------

81)
clear
echo "*************************************"
echo " 81 - Restart                        "
echo "*************************************"
echo
echo "-------------------------------------------------"
echo " Start command help                              "
echo "-------------------------------------------------"
echo " 1. Single                                       "
echo "     Step1. Server     : cubrid server start database-name"
echo "     Step2. broker     : cubrid broker start        "
echo "     Step3. manager    : cubrid manager start       "
echo
echo " 2. HA                                           "
echo "     Step1. HA-Server  : cubrid hb start            "
echo "     Step2. broker     : cubrid broker start        "
echo "     Step3. manager    : cubrid manager start       "
echo "-------------------------------------------------"
echo
echo
echo "-------------------------------------------------"
echo " Stop command help                               "
echo "-------------------------------------------------"
echo " 1. Single                                       "
echo "     Step1. manager    : cubrid manager stop        "
echo "     Step2. broker     : cubrid broker stop         "
echo "     Step3. Server     : cubrid server stop database-name "
echo
echo " 2. HA                                           "
echo "     Step1. manager    : cubrid manager stop        "
echo "     Step2. broker     : cubrid broker stop         "
echo "     Step3. HA-Server  : cubrid hb stop             "
echo "-------------------------------------------------"
echo
echo " Press Enter to continue..."
read
;;

82)
clear
echo "*************************************"
echo " 82 - Add Volume                     "
echo "*************************************"
echo
echo "-------------------------------------------------"
echo " Add Volume command help                         "
echo "-------------------------------------------------"
echo " 1. usage   : cubrid addvoldb [OPTION] database-name"
echo
echo " 2. option  :                                    "
echo "             --db-volume-size=SIZE        size of additional volume; default: db_volume_size in cubrid.conf"
echo "             --max-writesize-in-sec=SIZE  the amount of volume written per second; (ex. 512K, 1M, 10M); default: not used; minimum: 160K"
echo "             -n, --volume-name=NAME       NAME of information volume; default: generate such as "db"_ext1)"
echo "             -F, --file-path=PATH         PATH for adding volume file; default: working directory"
echo "             --comment=COMMENT            COMMENT for adding volume file; default: none"
echo "             -p, --purpose=PURPOSE        PURPOSE for adding volume file; allowed:"
echo "                                                  DATA - only for data"
echo "                                                  INDEX - only for indices"
echo "                                                  TEMP - only for temporary"
echo "                                                  GENERIC - for all purposes"
echo "             -S, --SA-mode                stand-alone mode execution"
echo "             -C, --CS-mode                client-server mode execution"
echo
echo " 3. example :                                    "
echo "    3-1 Single                                   "
echo "        1) DATA  : cubrid addvoldb -p data --db-volume-size=1G database-name "
echo "        2) INDEX : cubrid addvoldb -p index --db-volume-size=1G database-name "
echo "        3) TEMP  : cubrid addvoldb -p temp --db-volume-size=1G database-name "
echo
echo "    3-2 HA-Server                                "
echo "        1) DATA  : cubrid addvoldb -p data --db-volume-size=1G database-name@localhost"
echo "        2) INDEX : cubrid addvoldb -p index --db-volume-size=1G database-name@localhost"
echo "        3) TEMP  : cubrid addvoldb -p temp --db-volume-size=1G database-name@localhost "
echo
echo "    3-3 Stand-alone mode(DB is not Running)      "
echo "        1) DATA  : cubrid addvoldb -S -p data --db-volume-size=1G database-name"
echo "        2) INDEX : cubrid addvoldb -S -p index --db-volume-size=1G database-name"
echo "        3) TEMP  : cubrid addvoldb -S -p temp --db-volume-size=1G database-name"
echo
echo " Press Enter to continue..."
read
;;

83)
clear
echo "*************************************"
echo " 83 - HA Warning Help                "
echo "*************************************"
echo
echo "-------------------------------------------------"
echo "  Remove Serial Cache help                       "
echo "-------------------------------------------------"
echo " 1. Serial Cache List Check                      "
echo "    - select * from db_serial where cached>num>0;"
echo " 2. Remove Serial Cache                          "
echo "    - alter serial <serial-name> nocache;         "
echo " 3. Remove Check                                 "
echo "    - select name, cached_num from db_serial where name='<serial_name>';"
echo "-------------------------------------------------"
echo
echo 
echo "-------------------------------------------------"
echo "  Conversion From CLOB To Varchar help           "
echo "-------------------------------------------------"
echo " 1. Clob List Check                              "
echo "    - select class_name, attr_name, data_type from db_attribute where data_type='CLOB';"
echo " 2. Conversion From Clob To Varchar              "
echo "     Step 1. add column Varchar                  "
echo "      - alter table <table_name> add column <new_column_name> varchar; "
echo "     Step 2. Conversion Clob_to_char             "
echo "      - update <table_name> set <new_column_name>=CLOB_TO_CHAR(old_column_name>;"
echo "     Step 3. drop column clob                    "
echo "      - alter table <table_name> drop column <old_column_name>;"
echo "     Step 4. rename column                       "
echo "      - alter table <table_name> rename column <new_column_name> as <old_column_name>;"
echo "-------------------------------------------------"
echo
echo
echo "-------------------------------------------------"
echo "  Conversion From BLOB To Bit varying help       "
echo "-------------------------------------------------"
echo " 1. Blob List Check                              "
echo "    - select class_name, attr_name, data_type from db_attribute where data_type='BLOB';"
echo " 2. Conversion From Blob To Bit varying          "
echo "     Step 1. add column Bit varying              "
echo "      - alter table <table_name> add column <new_column_name> bit varying;"
echo "     Step 2. Conversion Blob_to_bit varying      "
echo "      - update <table_name> set <new_column_name>=BLBO_TO_BIT(old_column_name>;"
echo "     Step 3. drop column blob                    "
echo "      - alter table <table_name> drop column <old_column_name>;"
echo "     Step 4. rename column                       "
echo "      - alter table <table_name> rename column <new_column_name> as <old_column_name>;"
echo "-------------------------------------------------"
echo

echo " Press Enter to continue..."
read
;;

q)
clear
break
;;
esac

done
