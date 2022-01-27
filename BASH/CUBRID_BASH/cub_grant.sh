#!/bin/bash
## encoding : utf-8
## Create by, CUBRID INC

## User Configuration Parameters
FILE_PATH="."
GRANT_DML="SELECT, DELETE, UPDATE, INSERT"
GRANT_DDL="ALTER, INDEX, EXECUTE"
GRANT_ALL="ALL PRIVILEGES"
##


## Tool Configuration Parameters
DB_NM=$1
GRANTEE_USER=$2
GRANTOR_USER=$3
GRANTOR_USER_PSW=$4
GRANT_OPTION=$5
##


## FUNCTION INFO
function usage(){
	echo "CUBRID DBMS, auto-generator for grant all tables"
	echo "usage : "
	echo "		sh cub_grant.sh <dbname> <grantee user> <grantor user> <grantor user password> <option>"
	echo
	echo "	<option>"
	echo "		-view : grantee user all grant view"
	echo "		-dml : default "$GRANT_DML
	echo "		-ddl : default "$GRANT_DDL
	echo "		-all : ALL PRIVILEGES(dml+ddl)"
	echo ""
	echo "	<file creation info>"
	echo "		default path: "$FILE_PATH
	echo "		-dml : "$FILE_PATH"/GRANT_DML.sql"
	echo "		-ddl : "$FILE_PATH"/GRANT_DDL.sql"
	echo "		-all : "$FILE_PATH"/GRANT_ALL.sql"
	echo ""

	exit 0
}


function grant_generator(){	
revers_word_arr=("absolute"  "action"  "add"  "add_months"  "after"  "all"  "allocate"  "alter" "and"  "any"  "are"  "as"  "asc"  "assertion"  "at"  "attach"  "attribute"  "avg"  "before"  "between"  "bigint" \
"bit"  "bit_length"  "blob"  "boolean"  "both"  "breadth"  "by"  "call"  "cascade"  "cascaded"  "case"  "cast"  "catalog"  "change"  "char"  "character"  "check"  "class"  "classes" \
"clob"  "close"  "coalesce"  "collate"  "collation"  "column"  "commit"  "connect"  "connect_by_iscycle"  "connect_by_isleaf"  "connect_by_root"  "connection"  "constraint"  "constraints"  "continue" \
"convert"  "corresponding"  "count"  "create"  "cross"  "current"  "current_date"  "current_datetime"  "current_time"  "current_timestamp"  "current_user"  "cursor"  "cycle"  "data"  "data_type"  "database" \
"date"  "datetime"  "day"  "day_hour"  "day_millisecond"  "day_minute"  "day_second"  "deallocate"  "dec"  "decimal"  "declare"  "default"  "deferrable"  "deferred"  "delete"  "depth"  "desc"  "describe" \
"descriptor"  "diagnostics"  "difference"  "disconnect"  "distinct"  "distinctrow"  "div"  "do"  "domain"  "double"  "duplicate"  "drop"  "each"  "else"  "elseif"  "end"  "equals"  "escape"  "evaluate"  "except"  "exception" \
"exec"  "execute"  "exists"  "external"  "extract"  "false"  "fetch"  "file"  "first"  "float"  "for"  "foreign"  "found"  "from"  "full"  "function"  "general"  "get"  "global"  "go"  "goto"  "grant"  "group" \
"having"  "hour"  "hour_millisecond"  "hour_minute"  "hour_second"  "identity"  "if"  "ignore"  "immediate"  "in"  "index"  "indicator"  "inherit"  "initially"  "inner"  "inout"  "input"  "insert"  "int"  "integer" \
"intersect"  "intersection"  "interval"  "into"  "is"  "isolation"  "join"  "key"  "language"  "last"  "leading"  "leave"  "left"  "less"  "level"  "like"  "limit"  "list"  "local"  "local_transaction_id" \
"localtime"  "localtimestamp"  "loop"  "lower"  "match"  "max"  "method"  "millisecond"  "min"  "minute"  "minute_millisecond"  "minute_second"  "mod"  "modify"  "module"  "month"  "multiset"  "multiset_of" \
"na"  "names"  "national"  "natural"  "nchar"  "next"  "no"  "none"  "not"  "null"  "nullif"  "numeric"  "object"  "octet_length"  "of"  "off"  "on"  "only"  "open"  "optimization"  "option"  "or"  "order"  "out"  "outer"  "output"  "overlaps" \
"parameters"  "partial"  "position"  "precision"  "prepare"  "preserve"  "primary"  "prior"  "privileges"  "procedure"  "query"  "read"  "real"  "recursive"  "ref"  "references"  "referencing"  "relative"  "rename"  "replace" \
"resignal"  "restrict"  "return"  "returns"  "revoke"  "right"  "role"  "rollback"  "rollup"  "routine"  "row"  "rownum"  "rows"  "savepoint"  "schema"  "scope"  "scroll"  "search"  "second"  "second_millisecond"  "section"  "select" \
"sensitive"  "sequence"  "sequence_of"  "serializable"  "session"  "session_user"  "set"  "set_of"  "seteq"  "shared"  "siblings"  "signal"  "similar"  "size"  "smallint"  "some"  "sql"  "sqlcode" \
"sqlerror"  "sqlexception"  "sqlstate"  "sqlwarning"  "statistics"  "string"  "subclass"  "subset"  "subseteq"  "substring"  "sum"  "superclass"  "superset"  "superseteq"  "sys_connect_by_path" \
"sys_date"  "sys_datetime"  "sys_time"  "sys_timestamp"  "sysdate"  "sysdatetime"  "system_user"  "systime"  "table"  "temporary"  "then"  "time"  "timestamp"  "timezone_hour"  "timezone_minute"  "to"  "trailing" \
"transaction"  "translate"  "translation"  "trigger"  "trim"  "true"  "truncate"  "under"  "union"  "unique"  "unknown"  "update"  "upper"  "usage"  "use"  "user"  "using"  "utime"  "value"  "values"  "varchar" \
"variable"  "varying"  "vclass"  "view"  "when"  "whenever"  "where"  "while"  "with"  "without"  "work"  "write" "xor"  "year"  "year_month"  "zone")

GRANTEE_USER=`echo $GRANTEE_USER |tr '[a-z]' '[A-Z]'`
tbl_lists=(`csql -u $GRANTOR_USER -p $GRANTOR_USER_PSW -c "SELECT class_name FROM db_class WHERE is_system_class='NO' AND owner_name='$GRANTEE_USER'" $DB_NM |grep -vE "class_name|===|rows selected|row selected|There are no results|^$" |sed 's/ //g'|sed "s/'//g"`)

if [ $GRANT_OPTION = "-view" ]
	then
			grant_view_tbl=`csql -u $GRANTOR_USER -p $GRANTOR_USER_PSW $DB_NM -c "SELECT * FROM db_auth WHERE grantee_name='$GRANTEE_USER'"`
			grant_view_chk=`echo "$grant_view_tbl" |grep -vE "===|There are no results.|row selected|rows selected"`
			
			if [ $grant_view_chk -z ]
				then
					echo $GRANTEE_USER "user grant info none"
					exit 0
				else
					echo "$grant_view_tbl"
					exit 0
			fi			
fi


if [ ${tbl_lists[@]} -z ]
	then
		echo $GRANTEE_USER "user tables none"
		echo ""
		exit 0
fi


	
		if [ $GRANT_OPTION == "-dml" ]
			then
				for tbl_nm in ${tbl_lists[@]}
					do
						revers_word_check=`echo ${revers_word_arr[@]} |grep -w $tbl_nm`
						
						if [ $revers_word_check -z ]
						then
								echo "GRANT "$GRANT_DML "ON " "$tbl_nm " " TO " "$GRANTEE_USER" ";" >> $FILE_PATH/GRANT_DML.sql	
						else								 	
								echo "GRANT "$GRANT_DML "ON " "["$tbl_nm"]" " TO " "$GRANTEE_USER" ";" >> $FILE_PATH/GRANT_DML.sql
						fi
					done
					echo "DML success"
					
		elif [ $GRANT_OPTION == "-ddl" ]
			then
				for tbl_nm in ${tbl_lists[@]}
					do
						revers_word_check=`echo ${revers_word_arr[@]} |grep -w $tbl_nm`
					
					if [ $revers_word_check -z ]
						then
							echo "GRANT "$GRANT_DDL "ON " "$tbl_nm " " TO " "$GRANTEE_USER" ";" >> $FILE_PATH/GRANT_DDL.sql
						else
							echo "GRANT "$GRANT_DDL "ON " "["$tbl_nm"]" " TO " "$GRANTEE_USER" ";" >> $FILE_PATH/GRANT_DDL.sql								
							
						fi
					done
					echo "DDL success"
					
		elif [ $GRANT_OPTION == "-all" ]
			then
				for tbl_nm in ${tbl_lists[@]}
					do
												
					revers_word_check=`echo ${revers_word_arr[@]} |grep -w $tbl_nm`
					
					if [ $revers_word_check -z ]
						then
							echo "GRANT "$GRANT_ALL "ON " "$tbl_nm " " TO " "$GRANTEE_USER" ";" >> $FILE_PATH/GRANT_ALL.sql
						else
							echo "GRANT "$GRANT_ALL "ON " "["$tbl_nm"]" " TO " "$GRANTEE_USER" ";" >> $FILE_PATH/GRANT_ALL.sql
						fi
					done
					echo "ALL PRIVILEGES success"
		elif [ $GRANT_OPTION -z ]
			then
				usage
				exit 0
		elif [ $GRANT_OPTION != "-dml" ] | [ $GRANT_OPTION != "-ddl" ] | [ $GRANT_OPTION != "-all" ]
			then
				usage
				exit 0
		fi	
}


function grant_main(){
	validation_chk=`csql -u $GRANTOR_USER -p $GRANTOR_USER_PSW $DB_NM -c "SELECT 1"`
	if [ $validation_chk -z ]
		then
			usage
			exit 0
	fi	
	
	if [ $DB_NM -z ] | [ $GRANTEE_USER -z ] | [ $GRANTOR_USER -z ] | [ $GRANTOR_USER_PSW -z ]
		then
			usage
			exit 0
		else
		grant_generator
	fi
}
##


## function executions
grant_main 2>/dev/null

##
