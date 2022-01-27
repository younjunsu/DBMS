#!/bin/bash

# ================================
# CUBRID 9.3.9.0002 install Script
# ================================

# 큐브리드 설치 유저가 root면 설치가 취소 되는 함수
fn_cub_root_check(){
	USER_CHECK=`whoami`	
	
	if [ $USER_CHECK = "root" ] ; then
		echo
		echo " !!Warning								                                                  "
		echo " You can not run install script from root.                                  "
		echo " Please run install script in your cubrid account                           "
		echo
		echo
		exit
	fi
}


# 큐브리드 설치 경로를 확인하는 함수
fn_cub_install_dir(){
	echo "> Please enter the CUBRID installation path. (Default(enter) : /NIRS/CUBRID)"
	read INSTALL_PATH
	echo
	
	INSTALL_DIR=$INSTALL_PATH

	if [ $INSTALL_DIR -z ]  ;then
		echo "> CUBRID DBMS Install Directory /NIRS/CUBRID ? (Y or N)"
		read INSTALL_DIR_CHOICE
		echo
				
		if [ $INSTALL_DIR_CHOICE -z ] ; then
			echo "> exit"
			exit
		fi

			if [ $INSTALL_DIR_CHOICE = "Y"  -o $INSTALL_DIR_CHOICE = "y" ]  ; then
				
				INSTALL_DIR_CHECK=`ls /NIRS|grep -x "CUBRID" `
			
				if [ $INSTALL_DIR_CHECK -z ] ; then
					continue
				else
					echo "> Cannot Install CUBRID '/NIRS/CUBRID' : Path exists"
					echo
					echo "> exit"
					exit
				fi
						
				INSTALL_DIR=/NIRS
					
			elif [ $INSTALL_DIR_CHOICE = "N"  -o $INSTALL_DIR_CHOICE = "n" ] ; then
				echo
				echo "> exit"
				exit
			fi	
	else
	
		INSTALL_DIR_CHECK=`ls $INSTALL_PATH |grep -x "CUBRID" `
		
		if [ $INSTALL_DIR_CHECK -z ] ; then
			continue
		else
			echo "> Cannot Install CUBRID '""$INSTALL_PATH/CUBRID""' : Path exists"
			echo
			echo "> exit"
			exit
		fi
			
	fi
	
	echo "> Checking Path "$INSTALL_DIR"/CUBRID ? ( Y or N)"
	read INSTALL_PATH_CHOICE
	echo
	
	if [ $INSTALL_PATH_CHOICE -z ] ; then
		echo "> exit"
		exit
	fi
	
	if [ $INSTALL_PATH_CHOICE = "N"  -o $INSTALL_PATH_CHOICE = "n" ] ; then
		echo "> exit"
		exit
	elif [ $INSTALL_PATH_CHOICE  "Y"  -o $INSTALL_PATH_CHOICE = "y" ] ; then
		echo "> CUBRID Proceed with installation" 
		continue
	fi
}


# 큐브리드 환경변수 생성 완료 시 출력하는 함수
fn_cub_notice(){	  
	  echo "-------------------------------------------------------------------------"
		echo
		echo "CUBRID has been successfully installed.                                  "
		echo
		echo
		echo "If you want to use CUBRID, run the following commands                    "
		echo "  % . `echo ~`/cubrid.sh                                                 "
		echo "  % cubrid service start                                                 "
		echo
		echo
		echo "-------------------------------------------------------------------------"
		echo " CUBRID RECOMMAND OS limit config                                        "
		echo "-------------------------------------------------------------------------"
		echo " > /etc/security/limits.conf                                             "
		echo "  cubrid soft nofile 300000                                              "
		echo "  cubrid hard nofile 300000                                              "
		echo "  cubrid soft core unlimited                                             "
		echo "  cubrid hard core unlimited                                             "
		echo "																																				 "
		echo "-------------------------------------------------------------------------"
		echo " > User shoud be a member of the ""security"" group 										 "
		echo "   and /etc/hosts has a read Permission to the ""security"" group				 "
		echo "-------------------------------------------------------------------------"
		echo
}


# 큐브리드 환경변수 생성 취소 시 출력하는 함수
fn_cub_notice_false(){
	  echo "-------------------------------------------------------------------------"
		echo
		echo "CUBRID has been successfully installed.                                  "
		echo
		echo "> Check The CUBRID environment File.                                     "
		echo
		echo
		echo "-------------------------------------------------------------------------"
		echo " CUBRID RECOMMAND OS limit config                                        "
		echo "-------------------------------------------------------------------------"
		echo " > /etc/security/limits.conf                                             "
		echo "  cubrid soft nofile 300000                                              "
		echo "  cubrid hard nofile 300000                                              "
		echo "  cubrid soft core unlimited                                             "
		echo "  cubrid hard core unlimited                                             "
		echo "																																				 "
		echo "-------------------------------------------------------------------------"
		echo " > User shoud be a member of the ""security"" group 										 "
		echo "   and /etc/hosts has a read Permission to the ""security"" group				 "
		echo "-------------------------------------------------------------------------"
		echo
}


# 큐브리드 환경변수 입력 내용 함수
fn_cub_env_create(){
		echo "CUBRID="$INSTALL_DIR"/CUBRID" > ~/cubrid.sh
		echo "CUBRID_DATABASES="$INSTALL_DIR"/CUBRID/databases" >> ~/cubrid.sh
		echo "ld_lib_path=\`printenv LD_LIBRARY_PATH\`" >> ~/cubrid.sh
		echo "if [ \"\$ld_lib_path\" = \"\" ]" >> ~/cubrid.sh
		echo "then" >> ~/cubrid.sh
		echo "LD_LIBRARY_PATH=\$CUBRID/lib" >> ~/cubrid.sh
		echo "else" >> ~/cubrid.sh
		echo "LD_LIBRARY_PATH=\$CUBRID/lib:\$LD_LIBRARY_PATH" >> ~/cubrid.sh
		echo "fi" >> ~/cubrid.sh
		echo "SHLIB_PATH=\$LD_LIBRARY_PATH" >> ~/cubrid.sh
		echo "LIBPATH=\$LD_LIBRARY_PATH" >> ~/cubrid.sh
		echo "PATH=\$CUBRID/bin:\$CUBRID/cubridmanager:\$PATH" >> ~/cubrid.sh
		echo "export CUBRID" >> ~/cubrid.sh
		echo "export CUBRID_DATABASES" >> ~/cubrid.sh
		echo "export LD_LIBRARY_PATH" >> ~/cubrid.sh
		echo "export SHLIB_PATH" >> ~/cubrid.sh
		echo "export LIBPATH" >> ~/cubrid.sh
		echo "export PATH" >> ~/cubrid.sh
		echo ""  >> ~/cubrid.sh
		echo "export CUBRID_TMP=\$CUBRID/var/CUBRID_SOCK" >> ~/cubrid.sh
		echo "export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk" >> ~/cubrid.sh
		echo "export LD_LIBRARY_PATH=\$JAVA_HOME/jre/lib/amd64:\$JAVA_HOME/jre/lib/amd64/server:\$LD_LIBRARY_PATH" >> ~/cubrid.sh
}


# 큐브리드 환경변수 파일 확인
fn_cub_env_check(){
	ENV_CHECK_01=`ls -a ~/ |grep -x "cubrid.sh" `
	ENV_CHECK_02=`ls -a ~/ |grep -x ".cubrid.sh" `
	ENV_CHECK_FILE_01=`ls ~/cubrid.sh `
	ENV_CHECK_FILE_01=`ls ~/cubrid.sh `
	
	INSTALL_DIR_CHECK=`ls "$INSTALL_DIR"|grep -x "CUBRID" `
	
	if [ $INSTALL_DIR_CHECK -z ] ; then
		echo "> Please check the CUBRID installation path. "
		exit
	
	else
		if [ $ENV_CHECK_01 -z ]  ; then
			fn_cub_env_create
			fn_cub_profile
			fn_cub_notice		
			continue
		else
			echo "> The CUBRID environment File exists."
			echo $ENV_CHECK_FILE_01 $ENV_CHECK_FILE_02
			echo
			echo "> Do you want to CUBRID environment File overwrite it ? ( Y or N)"
			read  ENV_CHECK
			echo
			
			if [ $ENV_CHECK -z ] ; then
				fn_cub_notice_false
				echo
				exit
			fi
			
			if [ $ENV_CHECK = "N"  -o $ENV_CHECK = "n" ] ; then
				fn_cub_notice_false
				echo
				exit
			elif [ $ENV_CHECK = "Y"  -o $ENV_CHECK = "y" ] ; then
				fn_cub_env_create
				fn_cub_profile
				fn_cub_notice
							
			fi

		fi
	fi
	
}


# .bash_profile에 큐브리드 환경 변수 적용
fn_cub_profile(){
	BASH_CHECK=`grep "cubrid.sh" ~/.bash_profile 2>dev/null`
	
	if [ $BASH_CHECK -z ] 
	then
	    echo "                                                                                " >> ~/.bash_profile
	    echo "#-------------------------------------------------------------------------------" >> ~/.bash_profile
	    echo "# set CUBRID environment variables                                              " >> ~/.bash_profile
	    echo "#-------------------------------------------------------------------------------" >> ~/.bash_profile
	    echo ". $HOME/cubrid.sh                                                           " >> ~/.bash_profile
	fi
}



		# 큐브리드 사용자 확인(root면 취소)
		fn_cub_root_check 2>/dev/null
		
		# 큐브리드 설치 경로 확인
		fn_cub_install_dir  2>/dev/null

		# 큐브리드 엔진 설치 파일 압축 해제
		tar xzvfm CUBRID-9.3-latest-linux.x86_64.tar.gz -C $INSTALL_DIR 2>/dev/null
		
		# 환경변수 적용함수 수행
		fn_cub_env_check 2>/dev/null

