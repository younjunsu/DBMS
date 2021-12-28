-- LOG TRACE ON --

/* system trace on */
-- query
alter system add event (keyword like '%CSR%' and keyword like '%IMPORTANT%') as trace;

-- bind var
alter system add event 20847-20850 as trace;
alter system add event 24612-24613 as trace;




/* session trace on */
-- session
alter system add event (keyword like '%CSR%' and keyword like '%IMPORTANT%') as trace on session 21;

-- bind var
alter system add event 20847-20850 as trace on session 21;
alter system add event 24612-24613 as trace on session 21;




-- LOG TRACE OFF --

/* system trace off */
--query
--alter system drop event (keyword like '%CSR%' and keyword like '%IMPORTANT%') as trace ;

-- bind var
--alter system drop event 20847-20850 as trace;
--alter system drop event 24612-24613 as trace;


/* session trace off */
--query
--alter system drop event (keyword like '%CSR%' and keyword like '%IMPORTANT%') as trace on session 21;

-- bind var
--alter system drop event 20847-20850 as trace on session 21;
--alter system drop event 24612-24613 as trace on session 21;

