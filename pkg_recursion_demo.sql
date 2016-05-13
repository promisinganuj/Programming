create or replace package pkg_recursion_demo
as
  procedure cal_factorial(i_num int);
end pkg_recursion_demo;
/

create or replace package body pkg_recursion_demo
as
  v_result int := 1;
  v_number int;
  v_first_call boolean := true;
  procedure cal_factorial(i_num int)
  is
  begin
    if v_first_call then
      v_number := i_num;
      v_first_call := false;
    end if;
    if i_num < 0 then
      dbms_output.put_line('Please enter a valid whole number!');
    else
      if i_num <= 1 then
        dbms_output.put_line('Factorial of ' || to_char(v_number) || ': ' || to_char(v_result));
        v_result := 1;
        v_first_call := true;
      else
        v_result := v_result * i_num;
        cal_factorial (i_num - 1);
      end if;
    end if;
  end cal_factorial;
  
end pkg_recursion_demo;
/

begin
  for i in -1..10 loop
    pkg_recursion_demo.cal_factorial(i);
  end loop;
end;
/
