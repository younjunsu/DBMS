@echo off
rem ##########################################################
rem # Install Check Script.                                  #
rem # Made by Yeo Han Na                                     #
rem ##########################################################

set _rfile=install_check_result.txt

echo.
set /p syspw=Enter sys password [tibero] : 
echo.
echo y| del %_rfile%

rem 1. 설치계정
echo 1. 설치계정 >>%_rfile%
echo   - User : %username% /  >>%_rfile%
echo   - DB(sys) Password : %syspw% >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%


rem 2. 설치 디렉토리
echo 2. 설치 디렉토리 >>%_rfile%
echo - TB_HOME     : %TB_HOME% >>%_rfile%
echo - Datafile    :  >>%_rfile%
tbsql -s sys/%syspw% @.\sql\datafile.sql >>%_rfile%
echo - Redolog     :  >>%_rfile%
tbsql -s sys/%syspw% @.\sql\logfile.sql >>%_rfile%
echo - Controlfile :  >>%_rfile%
tbsql -s sys/%syspw% @.\sql\controlfile.sql >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 3. 설정 내역
echo 3. 설정 내역 >>%_rfile%
echo   - Listener Port :  >>%_rfile%
tbsql -s sys/%syspw% @.\sql\listener_port.sql >>%_rfile%
echo. >>%_rfile%
echo   - Log Mode      :   >>%_rfile%
tbsql -s sys/%syspw% @.\sql\log_mode.sql >>%_rfile%
echo. >>%_rfile%
echo   - Character Set :  >>%_rfile%
tbsql -s sys/%syspw% @.\sql\Character_set.sql >>%_rfile%
echo. >>%_rfile%
echo   - DB Name       :  >>%_rfile%
tbsql -s sys/%syspw% @.\sql\DB_name.sql >>%_rfile%

rem 4. JDBC Library 위치
echo 4. JDBC Library 위치 >>%_rfile%
echo   - JDK1.4 이하 : %TB_HOME%/client/lib/jar/tibero5-jdbc-14.jar >>%_rfile%
echo   - JDK1.5 이상 : %TB_HOME%/client/lib/jar/tibero5-jdbc.jar >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 5. Tibero 기동 명령
echo 5. Tibero 기동 명령 >>%_rfile%
echo   - tbboot >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 6. Tibero 종료 명령
echo 6. Tibero 종료 명령 >>%_rfile%
echo   - tbdown >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 7. Tibero 접속 방법
echo 7. Tibero 접속 방법 >>%_rfile%
echo   - tbsql Userid/Password[@alias] >>%_rfile%
echo      ex) tbsql sys/$syspw >>%_rfile%
echo          tbsql tibero/tmax@tibero >>%_rfile%
echo   - alias : %TB_HOME%/client/config/tbdsn.tbr 참조 >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 8. Tibero 버전 정보
echo 8. Tibero 버전 >>%_rfile%
tbsql -s sys/%syspw% @.\sql\version.sql >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

echo tbboot -version >>%_rfile%
echo. >>%_rfile%
echo -----------------------------------------------------------------  >>%_rfile%
call tbboot_v.bat  >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 9. Tibero 라이선스 정보
echo 9. Tibero 라이선스 정보 >>%_rfile%
tbsql -s sys/%syspw% @.\sql\license.sql >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%


rem 10. Tablespace 정보
echo 10. Tablespace 정보 >>%_rfile%
tbsql -s sys/%syspw% @.\sql\tablespace.sql >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 11. 서비스 기동 확인
echo 11. 서비스 기동 확인 >>%_rfile%
call tbdown_pid.bat  >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 12. 데이터파일 위치 확인
echo 12. 데이터파일 위치 확인 >>%_rfile%
tbsql -s sys/%syspw% @.\sql\datafile_rocate.sql >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 13. Tibero 환경파일(tip 파일)
echo 13. Tibero 환경파일(tip 파일) >>%_rfile%
echo %TB_HOME%/config/%TB_SID%.tip >>%_rfile%
echo ----------------------------------------------------------    >>%_rfile%
call tip.bat>>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

