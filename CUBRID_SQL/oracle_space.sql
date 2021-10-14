SELECT a.tablespace_name as tspace,
       (allspc.KB / 1024) as totalaloc,
       ((a.fretot - b.total_free ) / 1024 / 1024) as totalused,
       (b.total_free /1024) / 1024 as totalfree 
  FROM DUAL,
       (SELECT
              tablespace_name tablespace_name,
              SUM(bytes) fretot
         FROM dba_data_files
        WHERE tablespace_name like '%'
          AND tablespace_name not in ('SYSTEM','SYSAUX','UNDOTBS1','UNDOTBS2','EXAMPLE')
              group by tablespace_name
      ) a,
      (SELECT tablespace_name tablespace_name, 
              SQRT(MAX(blocks)/SUM(blocks))*(100/SQRT(SQRT(COUNT(blocks)) )) frag_index,
              SUM(bytes) total_free,
              MAX(bytes) max_hole,
              AVG(bytes) avg_hole,
              COUNT(*) cnt
         FROM dba_free_space
        WHERE tablespace_name like '%'
          AND tablespace_name not in ('SYSTEM','SYSAUX','UNDOTBS1','UNDOTBS2','EXAMPLE')
        GROUP BY tablespace_name
      ) b,
     (select table_space tablespace_name, sum(x) KB 
        from
             (select tablespace_name table_space,sum(bytes/1024) x 
                from dba_data_files
               where maxbytes=0 
                 and tablespace_name like '%'
                 and tablespace_name not in ('SYSTEM','SYSAUX','UNDOTBS1','UNDOTBS2','EXAMPLE')
               group by tablespace_name
               union all
              select tablespace_name table_space,sum(maxbytes/1024) x 
                from dba_data_files
               where tablespace_name like '%'
                 and tablespace_name not in ('SYSTEM','SYSAUX','UNDOTBS1','UNDOTBS2','EXAMPLE')
               group by tablespace_name
             )
       group by table_space
      ) allspc 
  WHERE a.tablespace_name = b.tablespace_name(+)
    and a.tablespace_name = allspc.tablespace_name(+);
