SELECT * 
  FROM (
        SELECT owner, object_type, COUNT (1)
          FROM dba_objects
         WHERE owner NOT LIKE 'ANONYMOUS%'
           AND owner NOT IN ('CSMIG','CTXSYS','DBSNMP','DEMO','DIP','DMSYS','PM','IX',
                             'DSSYS','EXFSYS','HR','OE','SH','LBACSYS','MDSYS','BI',
                             'OLAPSYS','ORDSYS','OUTLN','PERFSTAT','SYS','SYSTEM',
                            'TRACESVR','TSMSYS','XDB','WMSYS','WKPROXY','WKSYS','ODM','ODM_MTR',
                             'WK_TEST','APPLSYSPUB','APPLSYS','APPL','AP','AR','GL','APPQOSSYS',
                             'ORACLE_OCM','ORDDATA','ORDPLUGINS','OWBSYS','SI_INFORMTN_SCHEMA','SCOTT',
                             'MGMT_VIEW','OWBSYS_AUDIT','FLOWS_FILES','SYSMAN', 'APEX_030200','PUBLIC')
         GROUP BY owner, object_type
       )
ORDER BY 1, 2
