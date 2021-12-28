1. alter user [username] identified by [new_password];

2. drop user tibero cascade;
   alter user tibeor account lock;

3. alter system set USE_PROFILE=Y;

alter profile default limit password_life_time [life_time];
alter profile default limit password_verify_function verify_funciton; 

alter user [username] profile default;

4. revoke [privs_name] from [username];

7. revoke [privs_name] on [owner.table_name] form [grantee];

8. alter system set USE_PROFILE=Y;
alter profile default limit failed_login_attemps [failed_attempts];
alter profile default limit password_lock_time [lock_time];

10. revoke all on [user2].* from puser1] with grant option;

13. alter system set AUDIT_TRAIL=DB_EXTENDED;
alter system set AUDIT_TRAIL=OS;
alter system set AUDIT_FILE_DEST='[path]';
audit all privileges by access;






