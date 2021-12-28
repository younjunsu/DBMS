@echo off
rem #########################################################################################
rem # Tibero Active Session Monitoring
rem # created by : YoungDal,Kwon (IA/DB Technology Team) (2009.03)
rem #########################################################################################

setlocal
set USER=sys
set PASS=tibero


if '%1%'=='' (
	goto USAGE
) else (
	if '%2'=='' (
		goto USAGE
	) else (
		if /I '%1%'=='jcnt'       goto JCNT
		if /I '%1%'=='redowait'   goto REDOWAIT
		if /I '%1%'=='runsess'    goto RUNSESS
		if /I '%1%'=='session'    goto SESSION
		if /I '%1%'=='sessio'     goto SESSIO
		if /I '%1%'=='sessevent'  goto SESSEVENT
		if /I '%1%'=='sevent'     goto SEVENT
		if /I '%1%'=='spin'       goto SPIN
		if /I '%1%'=='swait'      goto SWAIT
		if /I '%1%'=='sysstat'    goto SYSSTAT
		if /I '%1%'=='tempseg'    goto TEMPSEG
		if /I '%1%'=='tran'       goto TRAN
		if /I '%1%'=='tablespa'   goto TABLESPA
		goto USAGE
	)
)
	



:USAGE
echo.
echo Usage : %0% {option} {interval}
echo.
  echo    Option    Description                     
  echo    --------  --------------------------------------
  echo    jcnt      jcntstat information
  echo    redowait  redo wait statistics 
  echo    runsess   current running session
  echo    session   current session
  echo    sessio    session i/o information
  echo    sessevent session event information
  echo    sevent    system event statistics
  echo    spin      spinlock statistics
  echo    swait     current session wait information
  echo    sysstat   sysstat information
  echo    tempseg   temp segment usage
  echo    tran      current transaction
  echo    tablespa  current tablespace
echo.
goto END


:jcnt
cls
echo JcntStat Information
echo ====================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\4_jcnt.sql.sql
timeout %2%
goto jcnt


:redowait
cls
echo Redo Nowait Information
echo =======================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\4_redonowait.sql
timeout %2%
goto redowait


:runsess
cls
echo Current Running Session Information
echo ===================================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\3_run_session.sql
timeout %2%
goto runsess


:session
cls
echo Current Session Information
echo ===========================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\3_current_session.sql
timeout %2%
goto session


:sessio
cls
echo Session I/O Information
echo =======================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\6_session_io.sql
timeout %2%
goto sessio


:sessevent
cls
echo Session Event Information
echo =========================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\4_session_event.sql
timeout %2%
goto sessevent


:sevent
cls
echo System Event Information
echo ========================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\4_system_event.sql
timeout %2%
goto sevent


:spin
cls
echo SpinLock Information
echo ====================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\2_latch.sql
timeout %2%
goto spin


:swait
cls
echo Current Session Wait Information
echo ================================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\4_session_wait.sql
timeout %2%
goto swait


:sysstat
cls
echo Sysstat Information
echo ===================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\4_sysstat.sql
timeout %2%
goto sysstat


:tempseg
cls
echo Tempseg Usage Information
echo =========================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\5_tempseg_usage.sql
timeout %2%
goto tempseg


:tran
cls
echo Current Transaction Information
echo ===============================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\3_current_transaction.sql
timeout %2%
goto tran


:tablespa
cls
echo Current Tablespace Information
echo ==============================
echo %DATE% %TIME%
tbsql -s %USER%/%PASS% @.\sql\5_tbs.sql
timeout %2%
goto tablespa



:END


endlocal
