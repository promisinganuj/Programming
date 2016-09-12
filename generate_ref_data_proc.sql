create or replace procedure prc_gen_ref_data_proc (
   p_proc_name       varchar2
  ,p_table_name      varchar2
  ,p_ext_table_name  varchar2
)
is
   l_proc_template clob := 
q'[
  procedure <proc_name>(
          p_job_log_id      in ref_subscr_job_log.subscriber_job_log_id%type
         ,p_job_detail_id   in ref_subscr_job_detail_cat.subscriber_job_details_id%type
    )
	is
	begin
        merge into <table_name> t
        using (select <col_list>
                 from <ext_table_name> ) s
            on (<join_condition>)
        when not matched then
            insert (<trg_col_list>)
            values (<src_col_list>)
        when matched then
            update
               set <set_clause>
             where (    <where_clause>
                   );

		grd_upload_helper.log_subscr_detail_log (p_job_log_id,
                                                 p_job_detail_id,
                                                 grd_upload_helper.c_info,
                                                 'Merged in to <table_name> ..' || sql%rowcount || '..rows');
	end <proc_name>;
]';

  g_proc_name      varchar2(30) := upper(p_proc_name);
  g_table_name     varchar2(30) := upper(p_table_name);
  g_ext_table_name varchar2(30) := upper(p_ext_table_name);

  function get_join_condition
  return varchar2
  is
    l_join_condition varchar2(4000);
  begin
    select listagg('s.' || lower(ucc.column_name) || ' = t.' || lower(ucc.column_name), ' and ') within group (order by ucc.position)
      into l_join_condition
      from user_constraints uc
           inner join
           user_cons_columns ucc on (uc.table_name = g_table_name and uc.constraint_type = 'P' and uc.constraint_name = ucc.constraint_name);

    return l_join_condition;

  end get_join_condition;
  
  function get_col_list (p_target_flag varchar2)
  return varchar2
  is
    l_column_list varchar2(4000);
  begin
    select listagg(case p_target_flag
                     when 'O' then ''
                     when 'S' then 's.'
                     when 'T' then 't.'
                   end || lower(utc.column_name), CHR(10) || '                    ,') within group (order by utc.column_id)
      into l_column_list
      from user_tab_columns utc
     where table_name = g_table_name;
     
     return l_column_list;
  end get_col_list;
  
  function get_set_clause
  return varchar2
  is
    l_set_clause varchar2(4000);
  begin
    select listagg( 't.' || rpad(lower(utc.column_name),30, ' ') || ' = s.' || lower(utc.column_name), CHR(10) || '                   ,') within group (order by utc.column_id)
      into l_set_clause
      from user_tab_columns utc
     where table_name = g_table_name
       and column_name not in (select ucc.column_name
                                 from user_constraints uc
                                      inner join
                                      user_cons_columns ucc on (uc.table_name = g_table_name and
                                                                uc.constraint_type = 'P' and
                                                                uc.constraint_name = ucc.constraint_name));
    return l_set_clause;
  end get_set_clause;
  
  function get_where_condition
  return varchar2
  is
    l_where_clause varchar2(4000);
  begin
    select listagg( 'evaluate_usage.formcolumn (t.' || rpad(lower(utc.column_name),30, ' ') || ') != evaluate_usage.formcolumn (s.' || lower(utc.column_name)|| ')', CHR(10) || '                     or ') within group (order by utc.column_id)
      into l_where_clause
      from user_tab_columns utc
     where table_name = g_table_name
       and column_name not in (select ucc.column_name
                                 from user_constraints uc
                                      inner join
                                      user_cons_columns ucc on (uc.table_name = g_table_name and
                                                                uc.constraint_type = 'P' and
                                                                uc.constraint_name = ucc.constraint_name));
    return l_where_clause;
  end get_where_condition;

begin
  l_proc_template := replace(l_proc_template, '<proc_name>', p_proc_name); -- To the initial case
  l_proc_template := replace(l_proc_template, '<table_name>', lower(g_table_name));
  l_proc_template := replace(l_proc_template, '<ext_table_name>', lower(g_ext_table_name));

  l_proc_template := replace(l_proc_template, '<join_condition>', get_join_condition);
  l_proc_template := replace(l_proc_template, '<col_list>', get_col_list('O'));
  l_proc_template := replace(l_proc_template, '<trg_col_list>', get_col_list('T'));
  l_proc_template := replace(l_proc_template, '<src_col_list>', get_col_list('S'));

  l_proc_template := replace(l_proc_template, '<set_clause>', get_set_clause);
  l_proc_template := replace(l_proc_template, '<where_clause>', get_where_condition);

  dbms_output.put_line(l_proc_template);

end prc_gen_ref_data_proc;
/

sho err