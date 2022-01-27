#!/bin/bash

########### USER Configuration
	FULL_BACKUP_ARCHIVE_DATE=7
	INCRE_BACKUP_ARCHIVE_DATE=1

##############################

	DBNAME=$1
	LEVEL=$2
	HOST_NM=`hostname`
	BACKUP_DATE=`date +%Y%m%d_%H`
	BACKUP_DIR=/DB_BACKUP/CUBRID_BACKUP/$HOST_NM/$DBNAME/level$LEVEL/$BACKUP_DATE
	RM_BACKUP_DATE=`date -d "-"$INCRE_BACKUP_ARCHIVE_DATE" day" +%Y%m%d`
	RM_BACKUP_DATE=`date -d "-"$FULL_BACKUP_ARCHIVE_DATE" day" +%Y%m%d`
	
function CUBRID_BACKUP_RUN(){
	mkdir -p $BACKUP_DIR
	cubrid backupdb -C -D $BACKUP_DIR -l $LEVEL -z -o $BACKUP_DIR/${DBNAME}-backupdb-${LEVEL}.log $DBNAME@localhost
}

function ARCHIVE_BACKUP_RM(){
	if [ $LEVEL = 0 ]; then
		
		RM_BACKUP_DIR=/DB_BACKUP/CUBRID_BACKUP/$HOST_NM/$DBNAME/level$LEVEL/$RM_BACKUP_DATE
		rm -rf "$RM_BACKUP_DIR"_*

	elif [ $LEVEL = 1 ]; then
		
		RM_BACKUP_DIR=/DB_BACKUP/CUBRID_BACKUP/$HOST_NM/$DBNAME/level$LEVEL/$RM_BACKUP_DATE
		rm -rf "$RM_BACKUP_DIR"_*

	fi
}

CUBRID_BACKUP_RUN 2>/dev/null
ARCHIVE_BACKUP_RM 2>/dev/null
