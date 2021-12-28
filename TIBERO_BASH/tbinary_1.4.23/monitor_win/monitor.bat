@echo off
rem #-------------------------------------------------------------------------------
rem # @File name      : monitor.bat
rem # @Contents       : Tibero RDBMS Monitor Windows Ver3.0
rem # @Created by     : YoungDal,Kwon
rem # @Created date   : 2009.03
rem # @Team           : DB Tech
rem # @Modifed History 
rem #-------------------------------------------------------------------------------
rem # 2009.03.01 YoungDal,Kwon                (Ver1.0)
rem # 2011.02.01 Daegil, Park Modified        (Ver2.0)
rem # 2011.03.28 Gim Gwon Hwan Modified       (Ver2.2)
rem # 2011.04.05 Gim Gwon Hwan Modified       (Ver2.2.1)
rem # 2011.12.12 Gim Gwon Hwan Modified       (Ver2.2.2)
rem # 2016.02.02 Yeo Han Na Modified          (Ver3.0)
rem # 2016.09.27 Yeo Han Na Modified          (Ver3.0.1) 
rem #-------------------------------------------------------------------------------

cls
rem ############### CMD ENV ###############
title Tibero RDBMS Monitor Ver3.0
mode con cols=152 lines=200
rem #######################################

setlocal
echo =============================
echo  Tibero RDBMS Monitor Ver3.0 
echo =============================
echo.
echo ==================================================
echo  (Disclaimer)                                     
echo  These scripts come without warranty of any kind. 
echo  Use them at your own risk.                       
echo ==================================================
echo.

set USER=sys
set /p PASS=Enter SYS Password :


:SEL_NUM
rem set ver_sql="tbsql -s %USER%/%PASS% @.\sql\version_chk.sql"
rem for /F %%i IN ('%ver_sql%') DO set TVER_CHK=%%i

rem echo y| del .\version.txt

tbsql -s %USER%/%PASS% @.\sql\version_chk.sql >> version.txt
set ver_cmd="type .\version.txt"
for /F %%i IN ('%ver_cmd%') DO set TVER_CHK=%%i


set sql_id_cmd="type sql\sqlid_format.sql | bin\awk -F" " "{print $4}""
for /F %%i IN ('%sql_id_cmd%') DO set sql_id=%%i
echo =============================
echo  Tibero RDBMS Monitor Ver3.0 
echo =============================
echo   Tibero Version : %TVER_CHK%  (SQL_ID_FORMAT: %sql_id%)
echo  -----------------------------------------------------------------------------------
echo   1.GENERAL                                  2.SHARED MEMORY                        
echo  ----------------------------------------   ----------------------------------------
echo   11 - Instance/Database Info                21 - Database Buffer Hit Ratio         
echo   12 - Parameter Info                        22 - Shared Cache    Hit Ratio         
echo   13 - Tibero Memory Info                    23 - Spinlock(Latch) Hit Ratio         
echo   14 - Backup Status                                                                
echo  ----------------------------------------- -----------------------------------------
echo   3.SESSION                                  4.WAIT EVENT/LOCK                      
echo  ----------------------------------------   ----------------------------------------
echo   31 - Current Session Info                  41 - Current Lock Info                 
echo   32 - Current Running Session Info          42 - Hierarchical Lock Info            
echo   33 - Current Running Session Wait Info     43 - Hierarchical Lock Info(TAC)       
echo   34 - Running Session SQL Info              44 - System Event                      
echo   35 - Current Transaction                   45 - Session Event                     
echo   36 - Open Cursor                           46 - Session Wait                      
echo   37 - Current Session(TAC)                  47 - Sysstat                           
echo   38 - Current Running Session(TAC)          48 - Jcntstat                          
echo   39 - Current Running Session Wait(TAC)     49 - Redo Nowait Info                  
echo  ----------------------------------------- -----------------------------------------
echo   5.SPACE                                    6.I/O                                  
echo  ----------------------------------------   ----------------------------------------
echo   51 - Database File Info                    61 - File I/O Info                     
echo   52 - Tablespace Usage                      62 - Session I/O Info                  
echo   53 - Undo Segment Usage                    63 - Archivelog Count                  
echo   54 - Temp Segment Usage                                                           
echo  ----------------------------------------- -----------------------------------------
echo   7.OBJECT                                   8.SQL                                  
echo  ----------------------------------------   ----------------------------------------
echo   71 - Schema Object Count                   81 - SQL Plan(Input SQL_ID)            
echo   72 - Object Invalid Count                  82 - Top SQL                           
echo   73 - Object Invalid Object                 83 - Check Static Query Pattern        
echo   74 - Segment Size(Top 50)                                                         
echo  ----------------------------------------- -----------------------------------------
echo   9.APM (Use Carefully)                      0.OTHER                                
echo  ----------------------------------------   ----------------------------------------
echo   91 - Create APM Snapshot                   M - Auto Refresh Monitoring            
echo   92 - Create APM Snapshot For TAC           S - Save To File                       
echo   93 - Show APM Snapshot                     I - Setting SQL_ID Format              
echo   94 - Create APM Report                     X - EXIT                               
echo  -----------------------------------------------------------------------------------
echo.
set choice=0
set /p choice=Choose the Number : 

if not '%choice%'=='' set choice=%choice%
if '%choice%'=='11' goto 11
if '%choice%'=='12' goto 12
if '%choice%'=='13' goto 13
if '%choice%'=='14' goto 14
if '%choice%'=='21' goto 21
if '%choice%'=='22' goto 22
if '%choice%'=='23' goto 23
if '%choice%'=='31' goto 31
if '%choice%'=='32' goto 32
if '%choice%'=='33' goto 33
if '%choice%'=='34' goto 34
if '%choice%'=='35' goto 35
if '%choice%'=='36' goto 36
if '%choice%'=='37' goto 37
if '%choice%'=='38' goto 38
if '%choice%'=='39' goto 39
if '%choice%'=='41' goto 41
if '%choice%'=='42' goto 42
if '%choice%'=='43' goto 43
if '%choice%'=='44' goto 44
if '%choice%'=='45' goto 45
if '%choice%'=='46' goto 46
if '%choice%'=='47' goto 47
if '%choice%'=='48' goto 48
if '%choice%'=='49' goto 49
if '%choice%'=='51' goto 51
if '%choice%'=='52' goto 52
if '%choice%'=='53' goto 53
if '%choice%'=='54' goto 54
if '%choice%'=='61' goto 61
if '%choice%'=='62' goto 62
if '%choice%'=='63' goto 63
if '%choice%'=='71' goto 71
if '%choice%'=='72' goto 72
if '%choice%'=='73' goto 73
if '%choice%'=='74' goto 74
if '%choice%'=='81' goto 81
if '%choice%'=='82' goto 82
if '%choice%'=='83' goto 83
if '%choice%'=='91' goto 91
if '%choice%'=='92' goto 92
if '%choice%'=='93' goto 93
if '%choice%'=='94' goto 94
if '%choice%'=='M' goto M
if '%choice%'=='m' goto M
if '%choice%'=='S' goto SAVE
if '%choice%'=='s' goto SAVE
if '%choice%'=='I' goto SQL_ID
if '%choice%'=='i' goto SQL_ID
if '%choice%'=='X' goto END
if '%choice%'=='x' goto END


echo '%choice%' is not valid please try again
echo Try Again..
echo.
pause
cls
goto SEL_NUM


rem 1.GENERAL ---------------------------------------

:11
cls
echo ============================
echo  Tibero Instance Infomation
echo ============================
tbsql -s %USER%/%PASS% @.\sql\1_instance.sql
echo.
pause
cls
goto SEL_NUM

:12
cls
echo =======================
echo  Parameter Information
echo =======================
tbsql -s %USER%/%PASS% @.\sql\1_parameter.sql
echo.
pause
cls
goto SEL_NUM

:13
cls
echo ======================
echo  TSM(SGA) Information
echo ======================
tbsql -s %USER%/%PASS% @.\sql\1_sga.sql
echo.
echo ===============================
echo  Tibero Used Memory Infomation 
echo ===============================
tbsql -s %USER%/%PASS% @.\sql\1_used_memory.sql
echo.
pause
cls
goto SEL_NUM

:14
cls
echo ===============
echo  Backup Status 
echo ===============
tbsql -s %USER%/%PASS% @.\sql\1_backup_status.sql
echo.
pause
cls
goto SEL_NUM


rem 2.SHARED_MEMORY ---------------------------------

:21
cls
echo ===========================
echo  Database Buffer Hit Ratio 
echo ===========================
tbsql -s %USER%/%PASS% @.\sql\2_bchr.sql
echo.
pause
cls
goto SEL_NUM

:22
cls
echo ========================
echo  Shared Cache Hit Ratio 
echo ========================
tbsql -s %USER%/%PASS% @.\sql\2_sharedcache.sql
echo.
pause
cls
goto SEL_NUM

:23
cls
echo ===========================
echo  Spinlock(Latch) Hit Ratio 
echo ===========================
tbsql -s %USER%/%PASS% @.\sql\2_latch.sql
echo.
pause
cls
goto SEL_NUM


rem 3.SESSION ---------------------------------------

:31
cls
echo.
echo ======================
echo  Current Session Info 
echo ======================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\3_current_session.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\3_current_session.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\3_current_session_6.sql )
echo.
pause
cls
goto SEL_NUM

:32
cls
echo =========================
echo  Current Running Session 
echo =========================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\3_run_session.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\3_run_session.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\3_run_session_6.sql )
echo.
pause
cls
goto SEL_NUM

:33
cls
echo ===========================
echo  Current Session Wait Info 
echo ===========================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\3_run_session_wait.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\3_run_session_wait_5SP1.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\3_run_session_wait_6.sql )
echo.
pause
cls
goto SEL_NUM

:34
cls
echo ======================
echo  Running Session(SQL) 
echo ======================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\3_running_sql.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\3_running_sql.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\3_running_sql_6.sql )
echo.
pause
cls
goto SEL_NUM

:35
cls
echo =====================
echo  Current Transaction 
echo =====================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\3_current_transaction.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\3_current_transaction.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\3_current_transaction_6.sql )
echo.
pause
cls
goto SEL_NUM

:36
cls
echo ====================
echo  Open Cursor Status 
echo ====================
tbsql -s %USER%/%PASS% @.\sql\3_open_cursor.sql
echo.
pause
cls
goto SEL_NUM

:37
cls
echo =========================
echo  Current Session For TAC 
echo =========================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\3_current_session_tac.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\3_current_session_tac.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\3_current_session_tac_6.sql )
echo.
pause
cls
goto SEL_NUM

:38
cls
echo =================================
echo  Current Running Session For TAC 
echo =================================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\3_run_session_tac.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\3_run_session_tac.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\3_run_session_tac_6.sql )
echo.
pause
cls
goto SEL_NUM

:39
cls
echo ===============================
echo   Current Session Wait For TAC 
echo ===============================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\3_run_session_wait_tac.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\3_run_session_wait_tac.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\3_run_session_wait_tac_6.sql )
echo.
pause
cls
goto SEL_NUM


rem 4.WAIT EVENT/LOCK--------------------------------

:41
cls
echo =======================
echo  Blocking/Waiting Lock 
echo =======================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\4_blockinglock.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\4_blockinglock.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\4_blockinglock_6.sql )
echo.
echo ======================
echo  DML Lock Information 
echo ======================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\4_lockinfo.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\4_lockinfo.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\4_lockinfo_6.sql )
echo.
echo ============================================
echo  Object Lock Information(Library cache Lock)
echo ============================================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\4_lockobj.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\4_lockobj.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\4_lockobj_6.sql )
echo.
pause
cls
goto SEL_NUM

:42
cls
echo =============================
echo  Hierarchical Lock Info(TAC) 
echo =============================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\4_hierarchical_lock_5.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\4_hierarchical_lock_5SP1.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\4_hierarchical_lock_6.sql )
echo.
pause
cls
goto SEL_NUM

:43
cls
echo ========================
echo  Hierarchical Lock Info 
echo ========================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\4_hierarchical_lock_tac.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\4_hierarchical_lock_tac_5SP1.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\4_hierarchical_lock_tac_6.sql )
echo.
pause
cls
goto SEL_NUM

:44
cls
echo ==============
echo  System Event 
echo ==============
tbsql -s %USER%/%PASS% @.\sql\4_system_event.sql
echo.
pause
cls
goto SEL_NUM

:45
cls
echo ===============
echo  Session Event 
echo ===============
tbsql -s %USER%/%PASS% @.\sql\4_session_event.sql
echo.
pause
cls
goto SEL_NUM

:46
cls
echo ==============
echo  Session Wait 
echo ==============
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\4_session_wait.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\4_session_wait.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\4_session_wait_6.sql )
echo.
pause
cls
goto SEL_NUM

:47
cls
echo =========
echo  Sysstat 
echo =========
tbsql -s %USER%/%PASS% @.\sql\4_sysstat.sql
echo.
pause
cls
goto SEL_NUM

:48
cls
echo ===========
echo  Jcnt Info 
echo ===========
tbsql -s %USER%/%PASS% @.\sql\4_jcnt.sql
echo.
pause
cls
goto SEL_NUM

:49
cls
echo =============
echo  Redo Nowait 
echo =============
tbsql -s %USER%/%PASS% @.\sql\4_redonowait.sql
echo.
pause
cls
goto SEL_NUM


rem 5.SPACE -----------------------------------------

:51
cls
echo ========================
echo  Controlfile Infomation 
echo ========================
tbsql -s %USER%/%PASS% @.\sql\5_control.sql
echo.
echo ====================
echo  Logfile Infomation 
echo ====================
tbsql -s %USER%/%PASS% @.\sql\5_logfile.sql
echo.
echo =====================
echo  Datafile Infomation 
echo =====================
tbsql -s %USER%/%PASS% @.\sql\5_datafile.sql
echo.
pause
cls
goto SEL_NUM

:52
cls
echo =======================
echo  Tablespace Infomation 
echo =======================
tbsql -s %USER%/%PASS% @.\sql\5_tbs.sql
echo.
echo ============================
echo  Temp Tablespace Infomation 
echo ============================
tbsql -s %USER%/%PASS% @.\sql\5_temp_tbs.sql
echo.
pause
cls
goto SEL_NUM

:53
cls
echo ==========================
echo  Current Undo Information 
echo ==========================
tbsql -s %USER%/%PASS% @.\sql\5_undo.sql
echo.
echo =================
echo  Undo Usage Type 
echo =================
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\5_undo_usage_type.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\5_undo_usage_type.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\5_undo_usage_type_6.sql )
echo.
pause
cls
goto SEL_NUM

:54
cls
echo ====================
echo  Temp Segment Usage 
echo ====================
tbsql -s %USER%/%PASS% @.\sql\5_tempseg_usage.sql
echo.
pause
cls
goto SEL_NUM


rem 6.I/O -------------------------------------------

:61
cls
echo ======================
echo  File I/O Information 
echo ======================
tbsql -s %USER%/%PASS% @.\sql\6_fileio.sql
echo.
pause
cls
goto SEL_NUM

:62
cls
echo =========================
echo  Session I/O Information 
echo =========================
tbsql -s %USER%/%PASS% @.\sql\6_session_io.sql
echo.
pause
cls
goto SEL_NUM

:63
cls
echo =====================================
echo  Archive Log Count (Archivelog Only) 
echo =====================================
tbsql -s %USER%/%PASS% @.\sql\6_loghistory.sql
echo.
pause
cls
goto SEL_NUM


rem 7.OBJECT ----------------------------------------

:71
cls
echo =====================
echo  Schema Object Count 
echo =====================
tbsql -s %USER%/%PASS% @.\sql\7_object_count.sql
echo.
pause
cls
goto SEL_NUM

:72
cls
echo ======================
echo  Object Invalid Count 
echo ======================
tbsql -s %USER%/%PASS% @.\sql\7_invalid_count.sql
echo.
pause
cls
goto SEL_NUM

:73
cls
echo =====================
echo  Object Invalid List 
echo =====================
tbsql -s %USER%/%PASS% @.\sql\7_invalid_object.sql
echo.
pause
cls
goto SEL_NUM

:74
cls
echo =======================
echo  Segment Size(Top 50)  
echo =======================
if '%TVER_CHK%'=='4SP1' (tbsql -s %USER%/%PASS% @.\sql\7_segment_size_4SP1.sql )
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\7_segment_size.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\7_segment_size.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\7_segment_size.sql )
echo.
pause
cls
goto SEL_NUM


rem 8.SQL -------------------------------------------

:81
cls
echo ==========
echo  SQL PLAN 
echo ==========
if '%TVER_CHK%'=='4SP1' (tbsql -s %USER%/%PASS% @.\sql\8_sql_plan_4SP1.sql )
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\8_sql_plan_5.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\8_sql_plan_5SP1.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\8_sql_plan_6.sql )
echo.
pause
cls
goto SEL_NUM

:82
cls
echo =========
echo  TOP SQL 
echo =========
if '%TVER_CHK%'=='4SP1' (tbsql -s %USER%/%PASS% @.\sql\8_topquery.sql )
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\8_topquery.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\8_topquery.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\8_topquery_6.sql )
echo.
pause
cls
goto SEL_NUM

:83
cls
echo ============================
echo  Check Static Query Pattern 
echo ============================
if '%TVER_CHK%'=='4SP1' (tbsql -s %USER%/%PASS% @.\sql\8_check_static_query.sql )
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\8_check_static_query.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\8_check_static_query.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\8_check_static_query_6.sql )
echo.
pause
cls
goto SEL_NUM


rem 9.APM -------------------------------------------

:91
cls
echo =====================
echo  APM Snapshot Create 
echo =====================
set /p cre_apm_snap=Create APM Snapshot?(Y/N) :
if '%cre_apm_snap%'=='Y' (tbsql -s %USER%/%PASS% @.\sql\9_apmcreate.sql )
if '%cre_apm_snap%'=='y' (tbsql -s %USER%/%PASS% @.\sql\9_apmcreate.sql )
echo.
pause
cls
goto SEL_NUM

:92
cls
echo =============================
echo  APM Snapshot Create For TAC 
echo =============================
set /p cre_apm_snap=Create APM Snapshot?(Y/N) :
if '%cre_apm_snap%'=='Y' (tbsql -s %USER%/%PASS% @.\sql\9_apmcreate_tac.sql )
if '%cre_apm_snap%'=='y' (tbsql -s %USER%/%PASS% @.\sql\9_apmcreate_tac.sql )
echo.
pause
cls
goto SEL_NUM

:93
cls
echo ===================
echo  APM Shapshot List 
echo ===================
if '%TVER_CHK%'=='4SP1' (tbsql -s %USER%/%PASS% @.\sql\9_apmshow.sql )
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\9_apmshow_5.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\9_apmshow_5SP1.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\9_apmshow_6.sql )
echo.
pause
cls
goto SEL_NUM

:94
cls
echo ===================
echo  APM Report Create 
echo ===================
if '%TVER_CHK%'=='4SP1' (tbsql -s %USER%/%PASS% @.\sql\9_apmshow.sql )
if '%TVER_CHK%'=='5' (tbsql -s %USER%/%PASS% @.\sql\9_apmshow_5.sql )
if '%TVER_CHK%'=='5SP1' (tbsql -s %USER%/%PASS% @.\sql\9_apmshow_5SP1.sql )
if '%TVER_CHK%'=='6' (tbsql -s %USER%/%PASS% @.\sql\9_apmshow_6.sql )

set /p cre_apm_snap=Create APM Report?(Y/N) :
set flag=true
if not %cre_apm_snap%==Y if not %cre_apm_snap%==y (set flag=false)
if %flag%==true if %TVER_CHK%==4SP1 (tbsql -s %USER%/%PASS% @.\sql\9_apmrpt.sql )
if %flag%==true if %TVER_CHK%==5 (tbsql -s %USER%/%PASS% @.\sql\9_apmrpt_5.sql )
if %flag%==true if %TVER_CHK%==5SP1 (tbsql -s %USER%/%PASS% @.\sql\9_apmrpt_5SP1.sql )
if %flag%==true if %TVER_CHK%==6 (tbsql -s %USER%/%PASS% @.\sql\9_apmrpt_6.sql )
echo.
pause
cls
goto SEL_NUM


rem 0.OTHER -----------------------------------------

:M
cls
echo ================================
echo  Tibero Auto Refresh Monitoring 
echo ================================

CALL tam.bat
set /p tam_option=Option : 
set /p tam_int=Interval : 
CALL tam.bat %tam_option% %tam_int%


:SAVE
cls
set FILENAME=monitor_%date:~5,2%%date:~8,2%%date:~0,4%.log
echo =========================== > ./log/%FILENAME%
echo  Tibero Monitoring Report   >> ./log/%FILENAME%
echo =========================== >> ./log/%FILENAME%
tbsql -s %USER%/%PASS% @.\sql\monitor.sql >> ./log/%FILENAME%
echo file saved...
echo FILNAME : ./log/%FILENAME%
echo.
echo ...end
pause
cls
goto SEL_NUM


:SQL_ID
cls
echo ==========================
echo  Setting SQL_ID format    
echo ==========================
echo Current format : 
rem type "%MONITOR%\sql\sqlid_format.sql"
type ".\sql\sqlid_format.sql"

echo.
echo ex) 99999999999999999999 or a25
echo.
set /p sql_id_format=Input SQL_ID FORMAT : 
echo column sql_id format %sql_id_format% > .\sql\sqlid_format.sql

goto SEL_NUM

:END
cls
echo Good bye...
echo.


endlocal
