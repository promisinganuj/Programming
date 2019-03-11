# Oracle
with tbl_a
  as (select level num
        from dual
     connect by
             level <= 1000),
     tbl_b
  as (select level num
        from dual
     connect by
             level <= 1000),
      tbl_int
  as (select a.num,
             sum(case mod(a.num, b.num) when 0 then 1 else 0 end) val
        from tbl_a a
             cross join
             tbl_b b
       where b.num <= a.num
       group by
             a.num)
select listagg(c.num, '&') within group (order by c.num)
  from tbl_int c
 where c.val = 2;
