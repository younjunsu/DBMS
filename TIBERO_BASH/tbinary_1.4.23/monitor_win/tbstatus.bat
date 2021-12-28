@echo off
rem #########################################################################################
rem # Tibero Status
rem # created by : YoungDal,Kwon (IA/DB Technology Team) (2009.03)
rem #########################################################################################

setlocal
set SRV_NAME=%TB_SID%
set USER=sys
set PASS=tibero

echo.
echo =======================
echo Tibero Status
echo -----------------------------------------------------------------------------------
echo   DB Name   = %SRV_NAME%

call tasklist | find "tbsvr.exe" | bin\wc -l > %TEMP%\tb_proc.tmp
FOR /F %%I in (%TEMP%\tb_proc.tmp) do (set PROC=%%I)


if '%PROC%'=='0' (

    echo.
    echo ----------------------------------------------
    echo Not Running...
    echo ----------------------------------------------

) else (

    goto PRINT_STATUS

)



:PRINT_STATUS

call tasklist | find "tblistener.exe" | bin\awk "{print $2}" > %TEMP%\tb_lsnr.tmp
call tbdown pid | find "MTHR" | bin\awk -F: "{print $1}" > %TEMP%\tb_mthr.tmp
call tbdown pid | find "BLKW" | bin\awk -F: "{print $1}" > %TEMP%\tb_blkw.tmp
call tbdown pid | find "LOGW" | bin\awk -F: "{print $1}" > %TEMP%\tb_logw.tmp
call tbdown pid | find "CKPT" | bin\awk -F: "{print $1}" > %TEMP%\tb_ckpt.tmp
call tbdown pid | find "LOGA" | bin\awk -F: "{print $1}" > %TEMP%\tb_loga.tmp
call tbdown pid | find "SEQW" | bin\awk -F: "{print $1}" > %TEMP%\tb_seqw.tmp
call tbsql -s %USER%/%PASS% @.\sql\proc_thr.sql | find /V "Disconnected" | find "WTHR_PROC_CNT" | bin\awk "{print $2}" > %TEMP%\tb_proccnt.tmp
call tbsql -s %USER%/%PASS% @.\sql\proc_thr.sql | find /V "Disconnected" | find "_WTHR_PER_PROC" | bin\awk "{print $2}" > %TEMP%\tb_thrcnt.tmp

FOR /F %%I in (%TEMP%\tb_lsnr.tmp) do (set LSNR=%%I)
FOR /F %%I in (%TEMP%\tb_mthr.tmp) do (set MTHR=%%I)
FOR /F %%I in (%TEMP%\tb_blkw.tmp) do (set BLKW=%%I)
FOR /F %%I in (%TEMP%\tb_logw.tmp) do (set LOGW=%%I)
FOR /F %%I in (%TEMP%\tb_ckpt.tmp) do (set CKPT=%%I)
FOR /F %%I in (%TEMP%\tb_loga.tmp) do (set LOGA=%%I)
FOR /F %%I in (%TEMP%\tb_seqw.tmp) do (set SEQW=%%I)
FOR /F %%I in (%TEMP%\tb_proccnt.tmp) do (set WPC=%%I)
FOR /F %%I in (%TEMP%\tb_thrcnt.tmp) do (set WTC=%%I)

echo.
echo   -------------------
echo   Running...
echo   -------------------
echo.
echo   ======================================
echo   BackGround Processor Status
echo   ======================================
echo   BackGroup Process Name                               Process ID
echo   --------------------------------------               ----------
echo   Tibero Listener                                      %LSNR%
echo   Monitor Process                                      %MTHR%
echo   DBWR(database buffer writer)                         %BLKW%
echo   LBWR(log buffer writer)                              %LOGW%
echo   CKPT(checkpoint)                                     %CKPT%
echo   LOGA(log archiver)                                   %LOGA%
echo   SEQW(Agent)                                          %SEQW%
echo.
echo   ======================================
echo   Working Process Status
echo   ======================================
echo   Working Process Count                                %WPC%
echo   Working Thread Count / Working Process               %WTC%
echo.
echo -----------------------------------------------------------------------------------
echo.


if exist %TEMP%\tb_lsnr.tmp ( del %TEMP%\tb_lsnr.tmp )
if exist %TEMP%\tb_mthr.tmp ( del %TEMP%\tb_mthr.tmp )
if exist %TEMP%\tb_blkw.tmp ( del %TEMP%\tb_blkw.tmp )
if exist %TEMP%\tb_logw.tmp ( del %TEMP%\tb_logw.tmp )
if exist %TEMP%\tb_ckpt.tmp ( del %TEMP%\tb_ckpt.tmp )
if exist %TEMP%\tb_loga.tmp ( del %TEMP%\tb_loga.tmp )
if exist %TEMP%\tb_seqw.tmp ( del %TEMP%\tb_seqw.tmp )
if exist %TEMP%\tb_proccnt.tmp ( del %TEMP%\tb_proccnt.tmp )
if exist %TEMP%\tb_thrcnt.tmp ( del %TEMP%\tb_thrcnt.tmp )


endlocal
