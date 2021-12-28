set linesize 200
col name for a30
col value for a30

select name,value from vt_parameter where name in ('LSNR_INVITED_IP','LSNR_DENIED_IP');
