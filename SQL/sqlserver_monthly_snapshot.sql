with
  tbl_date as 
    (select convert(datetime, '01/01/2000', 103) as dt
            -- DATEADD(month, DATEDIFF(month, 0, cast(getdate() as datetime)), 0) AS dt
      union all
     select dateadd(mm, 1, dt)
       from tbl_date),
  tbl_cal as
    (select top 1200 dt as [sm_date]
       from tbl_date),
  tmp_mem (mem_id, start_date, end_date, mem_balance) as
    (select 100 mem_id, convert(datetime, '12/01/2017', 103) start_date, convert(datetime, '15/01/2017', 103) end_date, 10050 mem_balance union
     select 100 mem_id, convert(datetime, '16/01/2017', 103) start_date, convert(datetime, '18/01/2017', 103) end_date, 10100 mem_balance union
    select 100 mem_id, convert(datetime, '19/01/2017', 103) start_date, convert(datetime, '04/02/2017', 103) end_date, 10150 mem_balance union
     select 100 mem_id, convert(datetime, '05/02/2017', 103) start_date, convert(datetime, '15/02/2017', 103) end_date, 10200 mem_balance union
     select 100 mem_id, convert(datetime, '16/02/2017', 103) start_date, convert(datetime, '09/04/2017', 103) end_date, 10250 mem_balance union
     select 100 mem_id, convert(datetime, '10/04/2017', 103) start_date, convert(datetime, '01/05/2017', 103) end_date, 10300 mem_balance union
     select 100 mem_id, convert(datetime, '02/05/2017', 103) start_date, convert(datetime, '01/01/2099', 103) end_date, 10350 mem_balance union
     select 101 mem_id, convert(datetime, '12/03/2017', 103) start_date, convert(datetime, '11/05/2017', 103) end_date, 20000 mem_balance union
     select 101 mem_id, convert(datetime, '12/05/2017', 103) start_date, convert(datetime, '01/01/2099', 103) end_date, 20050 mem_balance),
  tbl_mem as
    (select tmp_mem.*,
            lag(mem_balance, 1, null) over (partition by mem_id order by start_date) prev_bal
       from tmp_mem),
  tbl_monthly_cal as
    (select m.mem_id,
            c.sm_date
       from tbl_cal          c
            cross join
            (select distinct mem_id as mem_id
              from tbl_mem) m),
  tmp_final as
    (select cal.mem_id,
            cal.sm_date,
            mem.start_date,
            mem.end_date,
            mem.mem_balance,
            lag(mem.mem_balance, 1, null) over (partition by mem.mem_id order by cal.sm_date) prev_bal
       from tbl_monthly_cal     cal
            left join
            tbl_mem             mem on (cal.mem_id = mem.mem_id and cal.sm_date between mem.start_date and mem.end_date))
  select *
    from tmp_final fin
   where mem_balance <> isnull(prev_bal, -1)
   order by mem_id, sm_date
  option (maxrecursion 0);
