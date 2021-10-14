#!/bin/bash

##########################
# User Configuration     #
##########################

## arg setting
# db_name : DB Name
# log_sync_sec : log check interval
# log_sync_path : log destination directory
db_name=
arc_log_sync_sec=
arc_log_sync_path=



##########################
# System Configuration   #
##########################

## CUBRID env
# CUBRID environment check
# ENV_NO
# .cubrid.sh or cubrid.sh file check
env_nodat=`ls ~/cubrid.sh`
env_dat=`ls ~/.cubrid.sh`

	if [ $env_dat -z ] 
	then
		if [ $env_nodat -z ]
		then
			echo "Need to check CUBRID environment variables."
		else
			. ~/cubrid.sh
		fi
	else
		. ~/.cubrid.sh
	fi

##


## System env
# arc_log_path : archive log path
# arc_log_lists : archive log lists number
arc_log_path=`cat $CUBRID/databases/databases.txt |grep -w "$db_name" |awk '{print $4}'`
arc_log_lists=(`ls -lrt $arc_log_path |grep "lgar[0-9]" |sed 's/lgar/ /g' |awk '{print $NF}'`)

## 


##########################
# Backup Start           #
##########################

## Archive log recycle
# default : Shell run to Remove OLD backup archive log
# rm -rf disable
# rm -rf $arc_log_sync_path
rm -rf $arc_log_sync_path
sleep 1
mkdir -p $arc_log_sync_path

        while true
        do
                arc_log_first_check=`ls -lrt $arc_log_sync_path |grep "lgar[0-9]"`
                if [ $arc_log_first_check -z ]
                then
                        ## archive log first copy
                        arc_log_first_files=(`ls -lrt $arc_log_path |grep lgar[0-9] |awk '{print $NF}'`)
                        arc_log_first_num=`echo ${arc_log_first_files[0]}`
                        arc_log_end_num=`echo ${arc_log_first_files[@]} |awk '{print $NF}'`
                        arc_log_first_sync_cnt=`echo ${#arc_log_first_files[@]}`
                        cp $arc_log_path/"$db_name"_lgar* $arc_log_sync_path 
                        echo "< Archive Log First Sync > `date +%Y-%m-%d" "%T` - Copy $arc_log_first_num ~ $arc_log_end_num - log count $arc_log_first_sync_cnt" 
                else
                        arc_log_last_num=(`ls -lrt $arc_log_sync_path |grep "lgar[0-9]" |sed 's/lgar/ /g' |awk '{print $NF}' |tail -n 1`)
                        arc_log_lists=(`ls -lrt $arc_log_path |grep "lgar[0-9]" |sed 's/lgar/ /g' |awk '{print $NF}'`)
                        
                        for arc_log_num in ${arc_log_lists[@]}
                        do
                                ## archive log live copy (loop)
                                if [ $arc_log_last_num -lt $arc_log_num ]
                                then
                                        cp $arc_log_path/"$db_name"_lgar"$arc_log_num"  $arc_log_sync_path
                                        echo "< Archive Log Live Sync > `date +%Y-%m-%d" "%T` - lgar$arc_log_num"
                                fi
                        done
                fi

                sleep $arc_log_sync_sec
        done

#########################
# Backup End            #
#########################
