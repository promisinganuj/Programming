create table tbl_5_cons_dates
(	trx_date date, 
	id number
);

SET DEFINE OFF;
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('05/JAN/16','DD/MON/RR'),1);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('10/JAN/16','DD/MON/RR'),1);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('11/JAN/16','DD/MON/RR'),1);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('12/JAN/16','DD/MON/RR'),1);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('13/JAN/16','DD/MON/RR'),1);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('14/JAN/16','DD/MON/RR'),1);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('15/JAN/16','DD/MON/RR'),2);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('16/JAN/16','DD/MON/RR'),1);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('16/JAN/16','DD/MON/RR'),2);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('17/JAN/16','DD/MON/RR'),2);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('18/JAN/16','DD/MON/RR'),1);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('18/JAN/16','DD/MON/RR'),2);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('19/JAN/16','DD/MON/RR'),1);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('19/JAN/16','DD/MON/RR'),2);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('20/JAN/16','DD/MON/RR'),3);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('21/JAN/16','DD/MON/RR'),1);
Insert into TBL_5_CONS_DATES (TRX_DATE,ID) values (to_date('22/JAN/16','DD/MON/RR'),1);

commit;

select trx_date
      ,id
 from (
        select c.*
              ,count(*) over (partition by id, grp) grp_mem_cnt
          from (
                 select b.*
                       ,trx_date - to_date('01-Jan-2016', 'DD-Mon-YYYY') - row_number() over (partition by id order by trx_date) grp
                 from (
                        select a.*,
                               nvl(lag(trx_date) over (partition by id order by trx_date), trx_date) prev_trx_date,
                               nvl(lead(trx_date) over (partition by id order by trx_date), trx_date) next_trx_date
                          from tbl_5_cons_dates a
                      ) b
                 where trx_date - prev_trx_date = 1
                    or next_trx_date - trx_date = 1
               ) c
      ) d
 where grp_mem_cnt = 5;
 
 
 -- Simplified
 select trx_date
      ,id
 from (
        select c.*
              ,count(*) over (partition by id, grp) grp_mem_cnt
          from (
                 select a.*
                       ,trx_date - to_date('01-Jan-2016', 'DD-Mon-YYYY') - row_number() over (partition by id order by trx_date) grp
                  from tbl_5_cons_dates a
               ) c
      ) d
 where grp_mem_cnt = 5;

https://community.oracle.com/thread/1007478?start=0&tstart=0
