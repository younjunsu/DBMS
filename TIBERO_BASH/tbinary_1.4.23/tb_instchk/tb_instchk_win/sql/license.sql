SET FEEDBACK OFF
SET LINESIZE 100

col host format a20
col license_type format a15
col product_name format a15
col product_version format a15
col edition format a14
col issue_date format a20
col expire_date format a20
col limit_user format a20
col limit_cpu format a20

select host,license_type,product_name,product_version,edition from v$license;

select issue_date,expire_date,limit_user,limit_cpu from v$license;

exit