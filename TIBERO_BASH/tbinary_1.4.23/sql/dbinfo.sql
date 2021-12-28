-------------------------------------------------------------------
-- Tibero 설치 후 기본 정보 가져오는 스크립트 --
-------------------------------------------------------------------

SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

DECLARE

   shared_mem	number;
   shared_pool   	 number;
   db_cache	number;
   db_block	number;
   Fixed_mem	number;
   log_buffer	number;
   ex_mem	      	number;
   listener_port	varchar(50);
   db_name	varchar(50);
   shm_key		varchar(32);
   sem_key	varchar(32);
   wthr_proc_cnt	varchar(32);
   per_proc		varchar(50);
--   log_lvl		varchar(50);
   undo_retention	varchar(50);
   ts_name 		varchar(30);
   file_name 	varchar(100);
   c_status 		number;
   c_name 		varchar(100);
   l_group 		number;
   l_member 	varchar(100);

CURSOR CUR1 IS select * from dba_data_files ;
CURSOR CUR2 IS select * from  dba_temp_files ;
CURSOR CUR3 IS select * from v$controlfile ;
CURSOR CUR4 IS select * from v$logfile ;
   
BEGIN

select total into shared_mem from v$sga where name='SHARED MEMORY' ;
select total into shared_pool from v$sga where name='SHARED POOL MEMORY';
select value into db_cache from _vt_parameter where name='DB_CACHE_SIZE';
select value into db_block from _vt_parameter where name='DB_BLOCK_SIZE';
select value into log_buffer from _vt_parameter where name='LOG_BUFFER';
select value into ex_mem from _vt_parameter where name='EX_MEMORY_HARD_LIMIT';
Fixed_mem := shared_mem-(shared_pool+db_cache+log_buffer);
select value into listener_port from _vt_parameter where name='LISTENER_PORT';
select value into db_name from _vt_parameter where name='DB_NAME';
select value into shm_key from _vt_parameter where name='SHM_KEY';
select value into sem_key from _vt_parameter where name='SEM_KEY';
select value into wthr_proc_cnt from _vt_parameter where name='WTHR_PROC_CNT';
select value into per_proc from _vt_parameter where name='_WTHR_PER_PROC';
--select value into log_lvl from _vt_parameter where name='LOG_LVL';
select value into undo_retention from _vt_parameter where name='UNDO_RETENTION';

dbms_output.put_line(' ');
dbms_output.put_line(' ');
dbms_output.put_line('.====================.');
dbms_output.put_line('| MEMORY INFORMATION |');
dbms_output.put_line('====================================='
||'=======================================================');
dbms_output.put_line(' ');

dbms_output.put_line('Shared memory(Total memory)            :  '||TO_CHAR(shared_mem/1024/1024,'999,999,999')||' MB');
dbms_output.put_line('Fixed memory                           :  '||TO_CHAR(Fixed_mem/1024/1024,'999,999,999')||' MB');
dbms_output.put_line('Shared pool memory                     :  '||TO_CHAR(shared_pool/1024/1024,'999,999,999')||' MB');
dbms_output.put_line('db buffer cache                        :  '||TO_CHAR(db_cache/1024/1024,'999,999,999')||' MB');
dbms_output.put_line('log buffer                             :  '||TO_CHAR(log_buffer/1024/1024,'999,999,999')||' MB');

dbms_output.put_line(' ');

dbms_output.put_line('db_block_size                          :  '||TO_CHAR(db_block/1024,'999,999,999')||' KB');
dbms_output.put_line('ex_memory_hard_limit                   :  '||TO_CHAR(ex_mem/1024/1024,'999,999,999')||' MB');

dbms_output.put_line(' ');
dbms_output.put_line('.===================.');
dbms_output.put_line('| BASIC INFORMATION |');
dbms_output.put_line('====================================='
||'=======================================================');
dbms_output.put_line(' ');

dbms_output.put_line('LISTENER PORT                          :  '|| listener_port);
dbms_output.put_line('DB_NAME                                :  '|| db_name);
dbms_output.put_line('SHM_KEY                                :  '|| shm_key);
dbms_output.put_line('SEM_KEY                                :  '|| sem_key);
dbms_output.put_line('WTHR_PROC_CNT (PROCESS)                :  '|| wthr_proc_cnt||' [Process]');
dbms_output.put_line('_WTHR_PER_PROC (THREAD)                :  '|| per_proc||' [Thread]');
--dbms_output.put_line('LOG_LVL                                :  '|| log_lvl||' [Log Level]');
dbms_output.put_line('UNDO_RETENTION                         :  '|| undo_retention ||' [Sec]');

dbms_output.put_line(' ');
dbms_output.put_line('.======================.');
dbms_output.put_line('| DATAFILE INFORMATION |');
dbms_output.put_line('====================================='
||'=======================================================');
dbms_output.put_line(' ');

FOR REC1 IN CUR1 LOOP
DBMS_OUTPUT.PUT_LINE ( rpad(REC1.tablespace_name,39,' ')||': '||REC1.file_name);
END LOOP;

FOR REC2 IN CUR2 LOOP
DBMS_OUTPUT.PUT_LINE (rpad(REC2.tablespace_name,39,' ')||': '||REC2.file_name);
END LOOP;

dbms_output.put_line(' ');
dbms_output.put_line('.==========================.');
dbms_output.put_line('| CONTROL FILE INFORMATION |');
dbms_output.put_line('====================================='
||'=======================================================');
dbms_output.put_line(' ');

FOR REC3 IN CUR3 LOOP
DBMS_OUTPUT.PUT_LINE ('[status ('|| REC3.status|| ')] : '||rpad(REC3.name,70,' '));
END LOOP;
dbms_output.put_line(' ');
dbms_output.put_line('.=======================.');
dbms_output.put_line('| REDO FILE INFORMATION |');
dbms_output.put_line('====================================='
||'=======================================================');
dbms_output.put_line(' ');

FOR REC4 IN CUR4 LOOP
DBMS_OUTPUT.PUT_LINE ('Log Group(' || REC4.group# || ')' || ' : ' ||rpad(REC4.member,70,' '));
END LOOP;

DBMS_OUTPUT.PUT_LINE('====================================='
||'=======================================================');
END;
/
