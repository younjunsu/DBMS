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

rem 1. ��ġ����
echo 1. ��ġ���� >>%_rfile%
echo   - User : %username% /  >>%_rfile%
echo   - DB(sys) Password : %syspw% >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%


rem 2. ��ġ ���丮
echo 2. ��ġ ���丮 >>%_rfile%
echo - TB_HOME     : %TB_HOME% >>%_rfile%
echo - Datafile    :  >>%_rfile%
tbsql -s sys/%syspw% @.\sql\datafile.sql >>%_rfile%
echo - Redolog     :  >>%_rfile%
tbsql -s sys/%syspw% @.\sql\logfile.sql >>%_rfile%
echo - Controlfile :  >>%_rfile%
tbsql -s sys/%syspw% @.\sql\controlfile.sql >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 3. ���� ����
echo 3. ���� ���� >>%_rfile%
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

rem 4. JDBC Library ��ġ
echo 4. JDBC Library ��ġ >>%_rfile%
echo   - JDK1.4 ���� : %TB_HOME%/client/lib/jar/tibero5-jdbc-14.jar >>%_rfile%
echo   - JDK1.5 �̻� : %TB_HOME%/client/lib/jar/tibero5-jdbc.jar >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 5. Tibero �⵿ ���
echo 5. Tibero �⵿ ��� >>%_rfile%
echo   - tbboot >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 6. Tibero ���� ���
echo 6. Tibero ���� ��� >>%_rfile%
echo   - tbdown >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 7. Tibero ���� ���
echo 7. Tibero ���� ��� >>%_rfile%
echo   - tbsql Userid/Password[@alias] >>%_rfile%
echo      ex) tbsql sys/$syspw >>%_rfile%
echo          tbsql tibero/tmax@tibero >>%_rfile%
echo   - alias : %TB_HOME%/client/config/tbdsn.tbr ���� >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 8. Tibero ���� ����
echo 8. Tibero ���� >>%_rfile%
tbsql -s sys/%syspw% @.\sql\version.sql >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

echo tbboot -version >>%_rfile%
echo. >>%_rfile%
echo -----------------------------------------------------------------  >>%_rfile%
call tbboot_v.bat  >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 9. Tibero ���̼��� ����
echo 9. Tibero ���̼��� ���� >>%_rfile%
tbsql -s sys/%syspw% @.\sql\license.sql >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%


rem 10. Tablespace ����
echo 10. Tablespace ���� >>%_rfile%
tbsql -s sys/%syspw% @.\sql\tablespace.sql >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 11. ���� �⵿ Ȯ��
echo 11. ���� �⵿ Ȯ�� >>%_rfile%
call tbdown_pid.bat  >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 12. ���������� ��ġ Ȯ��
echo 12. ���������� ��ġ Ȯ�� >>%_rfile%
tbsql -s sys/%syspw% @.\sql\datafile_rocate.sql >>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

rem 13. Tibero ȯ������(tip ����)
echo 13. Tibero ȯ������(tip ����) >>%_rfile%
echo %TB_HOME%/config/%TB_SID%.tip >>%_rfile%
echo ----------------------------------------------------------    >>%_rfile%
call tip.bat>>%_rfile%
echo. >>%_rfile%
echo. >>%_rfile%

