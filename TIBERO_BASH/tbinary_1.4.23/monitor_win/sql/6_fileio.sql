set lines 150
set pagesize 40
set feedback off

col tablespace_name format a15
col file_name       format a50
col phyrds          format 999,999,999
col phywrts         format 999,999,999
col "Read(%)"       format 99999.9
col "Write(%)"      format 99999.9
col "Total_IO(%)"   format 9999.9
col "AvgTime(s)" format 9999.999

SELECT fl.tablespace_name,
       df.name file_name,
       fs.phyrds,
       fs.phywrts,
       round((PHYRDS/tot.rds)*100, 1) "Read(%)",
       round((PHYWRTS/decode(tot.wrts, 0, 1, tot.wrts))*100, 1) "Write(%)",
       round((phyrds + phywrts)/(tot.rds+tot.wrts)*100, 1) "Total_IO(%)" ,
       round(fs.avgiotim/1000,3) "AvgTime(s)"
FROM  v$datafile df
     ,v$filestat fs
     ,dba_data_files fl
     ,(select sum(phyrds) rds, sum(phywrts) wrts from v$filestat) tot
WHERE df.file# = fs.file#
  AND df.file# = fl.file_id
ORDER BY 1,2
/

exit
