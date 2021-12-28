set linesize 132
set feedback off

col "Time" format a19

SELECT  TO_CHAR(sysdate,'yyyy/mm/dd hh24:mi:ss') "Time"
			 ,"Physical read" 
       ,"Logical read"
       ,"Hit"
       ,CASE WHEN "Hit" > 90 then 'Good'
             WHEN "Hit" between 70 and 90 then 'Average'
             ELSE 'Not Good'
        END as "Status"
FROM
(      
 SELECT  pr1.value + pr2.value  "Physical read"   
        ,bg1.value + bg2.value + bg3.value "Logical read"   
        ,ROUND( (1 - (pr1.value + pr2.value) / (bg1.value + bg2.value + bg3.value) ) * 100, 2) "Hit"  
 FROM v$sysstat pr1, v$sysstat pr2,
      v$sysstat bg1 , v$sysstat bg2 , v$sysstat bg3
 WHERE pr1.name = 'block disk read' 
  and pr2.name = 'multi block disk read - blocks'
  and bg1.name = 'consistent block gets'
  and bg2.name = 'consistent multi gets - blocks'
  and bg3.name = 'current block gets' 
)
/



exit

