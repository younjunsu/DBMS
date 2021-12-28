SET feedback off
SET head off
select aggr_concat(value,'') v from vt_version where name in ('PRODUCT_MAJOR', 'PRODUCT_MINOR', 'TB_MAJOR', 'TB_MINOR');
SET feedback ON 
SET head ON 
exit