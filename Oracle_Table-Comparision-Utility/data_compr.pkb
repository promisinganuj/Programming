create or replace package body data_compr
is
  gc_delim_pipe    constant varchar2(1) := '|';
  gc_sdg_data01    constant varchar2(6) := 'DROP01';
  gc_sdg_data02    constant varchar2(6) := 'DROP02';
  gc_package_name  constant varchar2(30) := 'data_compr#';
  g_debugging               boolean := false;
  g_config_id               data_compr_config.config_id%type default -100;
  g_src_table_name          data_compr_config.src_table_name%type;
  g_trg_table_name          data_compr_config.trg_table_name%type;
  g_key_1                   data_compr_config.key_1%type;
  g_key_2                   data_compr_config.key_2%type;
  g_key_3                   data_compr_config.key_3%type;
  
  -- EXCEPTIONS --
  ex_template_not_found     exception;
  ex_template_not_found_msg varchar2(100) := 'No Template details found';
  pragma                    exception_init(ex_template_not_found, -20001);
  
  ex_config_not_found       exception;
  ex_config_not_found_msg   varchar2(100) := 'No Configuration details found';
  pragma                    exception_init(ex_config_not_found, -20002);

  procedure prc_set_debug(
    i_write_debug_info      boolean
  )
  is
  begin
    g_debugging := i_write_debug_info;
  end prc_set_debug;
  
  procedure prc_write_log(
    i_log_type              data_compr_log.log_type%type
    ,i_message              data_compr_log.log_message%type
    ,i_parameter_list       data_compr_log.parameters_list%type
    ,i_proc_name            data_compr_log.proc_name%type
  )
  is
    l_error_code            data_compr_log.error_code%type      := case when i_log_type in ('E', 'F') then sqlcode else null end;
    l_error_message         data_compr_log.error_message%type   := case when i_log_type in ('E', 'F') then sqlerrm else null end;
    l_error_backtrace       data_compr_log.error_backtrace%type := case when i_log_type in ('E', 'F') then dbms_utility.format_error_backtrace() else null end;
    pragma autonomous_transaction;
  begin
  
    if (i_log_type in ('I', 'W', 'E', 'F') or
      (i_log_type = 'D' and g_debugging)) then
      insert into data_compr_log(
        log_id
        ,log_type
        ,proc_name
        ,config_id
        ,log_message
        ,parameters_list
        ,error_code
        ,error_message
        ,error_backtrace
        ,log_timestamp
      )
      values(
        data_compr_log_seq.nextval
        ,decode(i_log_type, 'I', 'INFO', 'W', 'WARNING', 'E', 'ERROR', 'F', 'FATAL', i_log_type)
        ,gc_package_name || '.' || i_proc_name
        ,g_config_id
        ,i_message
        ,i_parameter_list
        ,l_error_code
        ,l_error_message
        ,l_error_backtrace
        ,systimestamp
      );
      commit;
    end if;

    if g_debugging then
      dbms_output.put_line(i_message);
    end if;
  end prc_write_log;

  function get_extn_table_template(
    i_template_id data_compr_template.template_id%type
  ) return clob
  is
    l_template               data_compr_template.template_val%type;
    l_proc_name              data_compr_log.proc_name%type := 'get_extn_table_template';
    cursor cur_template
    is
    select template_val
      from data_compr_template
     where template_id = i_template_id;
  begin
    open cur_template;
    
    fetch cur_template
     into l_template;
     
    if (nvl(l_template, empty_clob()) = empty_clob()) then
      raise_application_error(-20001, ex_template_not_found_msg);
    else
      return l_template;
    end if;

    close cur_template;
  end get_extn_table_template;

  procedure prc_add_record(
    i_key_1            varchar2
    ,i_key_2           varchar2 default null
    ,i_key_3           varchar2 default null
    ,i_change_type     varchar2
    ,i_column_name     varchar2 default null
    ,i_is_header       varchar2
    ,i_old_value       varchar2 default null
    ,i_new_value       varchar2 default null
  )
  is
    l_proc_name        data_compr_log.proc_name%type := 'prc_add_record';
    l_table_name       varchar2(30);
  begin
    if i_is_header = 'Y' then
      l_table_name := 'TABLE_NAME';
    else
      l_table_name := g_src_table_name;
    end if;

    insert into data_compr_report(
      report_id
      ,config_id
      ,date_generated
      ,src_table_name
      ,key_1
      ,key_2
      ,key_3
      ,change_type
      ,column_name
      ,old_value
      ,new_value
      ,is_header
      ,created_at
      ,updated_at
    )
    values(
      data_compr_report_seq.nextval
      ,g_config_id
      ,TO_CHAR(sysdate, 'DD-Mon-YYYY')
      ,l_table_name
      ,i_key_1
      ,i_key_2
      ,i_key_3
      ,i_change_type
      ,i_column_name
      ,i_old_value
      ,i_new_value
      ,i_is_header
      ,sysdate
      ,null
    );

  end prc_add_record;
  
  procedure prc_init(
    i_src_table_name          varchar2
    ,i_trg_table_name         varchar2
    ,i_key_1                  varchar2
    ,i_key_2                  varchar2
    ,i_key_3                  varchar2
  )
  is
    l_proc_name        data_compr_log.proc_name%type := 'prc_init';
  begin
    execute immediate 'alter session set nls_date_format=''DD-Mon-YYYY HH24:MI:SS'' ';
    g_src_table_name := UPPER(i_src_table_name);
    g_trg_table_name := UPPER(i_trg_table_name);
    g_key_1 := UPPER(i_key_1);
    g_key_2 := UPPER(i_key_2);
    g_key_3 := UPPER(i_key_3);
    
    execute immediate 'delete from data_compr_report
                        where config_id = :1' using g_config_id;
                          
    prc_add_record(
      i_key_1            => 'KEY_1(' || g_key_1  || ')'
      ,i_key_2           => 'KEY_2(' || g_key_2  || ')'
      ,i_key_3           => 'KEY_3(' || g_key_3  || ')'
      ,i_change_type     => 'CHANGE_TYPE'
      ,i_column_name     => 'COLUMN_NAME'
      ,i_old_value       => 'OLD_VALUE'
      ,i_new_value       => 'NEW_VALUE'
      ,i_is_header       => 'Y'
    );
  end prc_init;
                    
  function get_col_list(
    i_table_name              varchar2
  ) return clob
  is
    l_proc_name               data_compr_log.proc_name%type := 'get_col_list';
    v_col_list clob;
  begin
    select listagg('a.' || column_name, ',')
           within group(order by case column_name 
                                    when g_key_1 then
                                      -2 
                                    when g_key_2 then
                                      -1 
                                    when g_key_3 then 
                                      0 
                                    else 
                                      column_id 
                                end)
      into v_col_list
      from user_tab_cols a
     where table_name = i_table_name
       and column_name not in (select column_name
                                 from data_compr_excl_col b
                                where b.config_id = g_config_id);
     
    return trim(both ',' from v_col_list);
  end get_col_list;
  
  function get_col_datatype(
    i_table_name      varchar2
    ,i_col_name       varchar2
  ) return varchar2
  is
    l_proc_name           data_compr_log.proc_name%type := 'get_col_datatype';
    l_col_datatype        varchar2(30);
  begin
    select data_type
      into l_col_datatype
      from user_tab_cols
     where table_name = i_table_name
       and column_name = i_col_name;
     
     return l_col_datatype;
  end get_col_datatype;
  
  function get_join_condition(
    i_colummn_name    varchar2
  ) return varchar2
  is
    l_join_cond       varchar2(4000);
    l_col_datatype    varchar2(30);
    l_default_val     varchar2(30);
  begin
    if i_colummn_name is not null then
      l_col_datatype := get_col_datatype(
        i_table_name  => g_src_table_name
        ,i_col_name   => i_colummn_name
      );
      
      l_join_cond := 'and nvl(a.' || i_colummn_name || ', <p_default>) = nvl(b.' || i_colummn_name || ', <p_default>)';
      
      l_default_val := case l_col_datatype
                         when 'NUMBER'      then '-1'
                         when 'INTEGER'     then '-1'
                         when 'FLOAT'       then '-.01'
                         when 'CHAR'        then '''X'''
                         when 'VARCHAR2'    then '''X'''
                         when 'DATE'        then 'to_date(''01-01-1001'', ''dd-mm-yyyy'')'
                         else                    '''X'''
                      end;
      return replace(l_join_cond, '<p_default>', l_default_val);
    else
      return null;
    end if;
  end get_join_condition;

  function get_final_sql(
    i_col_list        clob
  ) return clob
  is
    l_proc_name       data_compr_log.proc_name%type := 'get_final_sql';
    l_join_cond       varchar2(4000);
    l_sql_text        clob := 'select <col_list> from <main_table> a full outer join <temp_table> b on (<join_condition>)';
  begin
    l_sql_text := replace(l_sql_text, '<col_list>'  , i_col_list || ', ' || replace(i_col_list, 'a.', 'b.'));
    l_sql_text := replace(l_sql_text, '<main_table>', g_src_table_name);
    l_sql_text := replace(l_sql_text, '<temp_table>', g_trg_table_name);

    l_join_cond := l_join_cond || get_join_condition(g_key_1);
    l_join_cond := l_join_cond || get_join_condition(g_key_2);
    l_join_cond := l_join_cond || get_join_condition(g_key_3);
    
    prc_write_log(
      i_log_type => 'I'
      ,i_message => 'Final join condition...'
      ,i_parameter_list => ltrim(l_join_cond, 'and')
      ,i_proc_name => l_proc_name
    );
    return replace(l_sql_text, '<join_condition>', ltrim(l_join_cond, 'and'));
  end get_final_sql;
  
  function format_str(
    i_string              varchar2
  ) return varchar2
  is
    l_proc_name       data_compr_log.proc_name%type := 'format_str';
    l_string varchar2(4000) := ltrim(i_string, ',');
  begin
    return 
      case regexp_count(l_string, ',')
        when 0 then
          l_string || ',,'
        when 1 then
          l_string || ','
        else
          l_string
      end;
  end format_str;

  procedure prc_process_data
  is
    l_proc_name       data_compr_log.proc_name%type := 'prc_process_data';
    l_cur               integer default dbms_sql.open_cursor;
    l_desctab           dbms_sql.desc_tab;
    l_colcount          number;
    l_col_list          clob;
    l_sql_text          clob;
    l_columnvalue       varchar2(4000);
    l_status            integer;
    l_col_old           varchar2(4000);
    l_col_new           varchar2(4000);
    l_key_col_list      varchar2(4000);
    l_key_val_list_old  varchar2(4000);
    l_key_val_list_new  varchar2(4000);
    l_existing_record   boolean;
  begin
    l_col_list := get_col_list(
      i_table_name          => g_src_table_name
    );
    
    l_sql_text := get_final_sql(
      i_col_list            => l_col_list
    );
    
    prc_write_log(
      i_log_type => 'I'
      ,i_message => 'SQL Generated...'
      ,i_parameter_list => l_sql_text
      ,i_proc_name => l_proc_name
    );

    dbms_sql.parse(l_cur, l_sql_text, dbms_sql.native);
    dbms_sql.describe_columns(l_cur, l_colcount, l_desctab);
  
    for i in 1..l_colcount loop
      dbms_sql.define_column(l_cur, i, l_columnvalue, 4000);
    end loop;
  
    l_status := dbms_sql.execute(l_cur);
  
    while (dbms_sql.fetch_rows(l_cur) > 0) loop
      l_existing_record   := false;
      l_key_col_list      := null;
      l_key_val_list_old  := null;
      l_key_val_list_new  := null;

      for i in 1..l_colcount/2 loop
        dbms_sql.column_value(l_cur, i, l_columnvalue);
        l_col_old := l_columnvalue;
        dbms_sql.column_value(l_cur, l_colcount/2 + i, l_columnvalue);
        l_col_new := l_columnvalue;

        if l_desctab(i).col_name IN (g_key_1, g_key_2, g_key_3) then
          l_key_col_list      := l_key_col_list     || ',' || l_desctab(i).col_name;
          l_key_val_list_old  := l_key_val_list_old || ',' || l_col_old;
          l_key_val_list_new  := l_key_val_list_new || ',' || l_col_new;
          
          if l_desctab(i).col_name = coalesce(g_key_3, g_key_2, g_key_1) then
            case
              when nvl(replace(replace(l_key_val_list_old, ',', ''),' ', ''), 'X') = 'X' then
                prc_write_log(
                  i_log_type => 'D'
                  ,i_message => 'RECORD ADDED - ' || ltrim(l_key_col_list, ',') || ': ' || format_str(l_key_val_list_new)
                  ,i_parameter_list => null
                 ,i_proc_name => l_proc_name
                );
                prc_add_record(
                  i_key_1            => regexp_replace(format_str(l_key_val_list_new), '(.*),(.*),(.*)' ,'\1')
                  ,i_key_2           => regexp_replace(format_str(l_key_val_list_new), '(.*),(.*),(.*)' ,'\2')
                  ,i_key_3           => regexp_replace(format_str(l_key_val_list_new), '(.*),(.*),(.*)' ,'\3')
                  ,i_change_type     => 'ADDED'
                  ,i_is_header       => 'N');
              when nvl(replace(replace(l_key_val_list_new, ',', ''),' ', ''), 'X') = 'X' then
                prc_write_log(
                  i_log_type => 'D'
                  ,i_message => 'RECORD DELETED - '  || ltrim(l_key_col_list, ',') || ': ' || format_str(l_key_val_list_old)
                  ,i_parameter_list => null
                  ,i_proc_name => l_proc_name
                );
                prc_add_record(
                  i_key_1            => regexp_replace(format_str(l_key_val_list_old), '(.*),(.*),(.*)' ,'\1')
                  ,i_key_2           => regexp_replace(format_str(l_key_val_list_old), '(.*),(.*),(.*)' ,'\2')
                  ,i_key_3           => regexp_replace(format_str(l_key_val_list_old), '(.*),(.*),(.*)' ,'\3')
                  ,i_change_type     => 'DELETED'
                  ,i_is_header       => 'N');
              else
                prc_write_log(
                  i_log_type => 'D'
                  ,i_message => 'EXISTING RECORD - ' || ltrim(l_key_col_list, ',') || ': ' || format_str(l_key_val_list_old)
                  ,i_parameter_list => null
                  ,i_proc_name => l_proc_name
                );
                l_existing_record := true;
            end case;
          end if;
        else
          if (l_existing_record) then
            if ((l_col_old is null and l_col_new is not null) or
              (l_col_old is not null and l_col_new is null) or
              (l_col_old <> l_col_new)) then
                prc_write_log(
                  i_log_type => 'D'
                  ,i_message => '  Column Name: '  || l_desctab(i).col_name
                  ,i_parameter_list => '    Old Value: '  || l_col_old
                  ,i_proc_name => l_proc_name
                );
                prc_write_log(
                  i_log_type => 'D'
                  ,i_message => '  Column Name: '  || l_desctab(i).col_name
                  ,i_parameter_list => '    New Value: '  || l_col_new
                  ,i_proc_name => l_proc_name
                );
              prc_add_record(
                i_key_1            => regexp_replace(format_str(l_key_val_list_old), '(.*),(.*),(.*)' ,'\1')
                ,i_key_2           => regexp_replace(format_str(l_key_val_list_old), '(.*),(.*),(.*)' ,'\2')
                ,i_key_3           => regexp_replace(format_str(l_key_val_list_old), '(.*),(.*),(.*)' ,'\3')
                ,i_change_type     => 'UPDATED'
                ,i_column_name     => l_desctab(i).col_name
                ,i_old_value       => l_col_old
                ,i_new_value       => l_col_new
                ,i_is_header       => 'N');
            else
              null;
            end if;
          end if;
        end if;
      end loop;
    end loop;
  end prc_process_data;
  
  function existing_table (
    i_table_name            user_tables.table_name%type
  ) return boolean
  is
    l_proc_name             data_compr_log.proc_name%type := 'existing_table';
    l_val                   number;
    cursor cur_table
    is
    select 1
      from user_tables
     where table_name = i_table_name;
  begin
    open cur_table;
    fetch cur_table
     into l_val;
    close cur_table;
    
    if l_val is null then
      return false;
    else
      return true;
    end if;
  
  end existing_table;
  
  procedure prc_create_ext_tables(
    i_config_rec             data_compr_config%rowtype
    ,i_template              data_compr_template.template_val%type
  )
  is
    l_proc_name       data_compr_log.proc_name%type := 'prc_create_ext_tables';
  begin
    if existing_table(i_config_rec.src_table_name) then
      execute immediate 'drop table ' || i_config_rec.src_table_name;
    end if;
   
    if existing_table(i_config_rec.trg_table_name) then
      execute immediate 'drop table ' || i_config_rec.trg_table_name;
    end if;

    execute immediate replace(
                          replace(
                            replace(i_template, '<table_name>', i_config_rec.src_table_name), 
                              '<db_dir>', i_config_rec.src_file_dir),
                            '<file_name>', i_config_rec.src_file_name);
  
    execute immediate replace(
                          replace(
                            replace(i_template, '<table_name>', i_config_rec.trg_table_name), 
                              '<db_dir>', i_config_rec.trg_file_dir),
                          '<file_name>', i_config_rec.trg_file_name);

  end prc_create_ext_tables;
  
  procedure prc_generate_file(
    i_config_rec        data_compr_config%rowtype
  )
  is
    l_proc_name       data_compr_log.proc_name%type := 'prc_generate_file';
    type row_aat is table of varchar2(32767)
      index by pls_integer;
    l_aa_rows           row_aat;
    l_file              utl_file.file_type;
    l_limit    constant pls_integer := 100;
    l_file_name         data_compr_config.src_file_dir%type;
    l_rc                sys_refcursor;
  begin
    l_file_name := REGEXP_REPLACE(
      i_config_rec.src_file_name
      ,'(.*)_drop\d{2}.txt'
      , '\1_' || lower(i_config_rec.src_data_group)|| '_' || lower(i_config_rec.trg_data_group) || '_diff.txt');

    l_file := utl_file.fopen(i_config_rec.src_file_dir, l_file_name, 'w');
    
    open l_rc
      for select
            case a.is_header
              when 'Y' then 'REPORT_ID'
              else          to_char(a.report_id)
            end                   || gc_delim_pipe ||
            case a.is_header
              when 'Y' then 'CONFIG_ID'
              else          to_char(a.config_id)
            end                   || gc_delim_pipe ||
            case a.is_header
              when 'Y' then 'DATE_GENERATED'
              else          a.date_generated
            end                   || gc_delim_pipe ||
            a.src_table_name      || gc_delim_pipe ||
            a.key_1               || gc_delim_pipe ||
            a.key_2               || gc_delim_pipe ||
            a.key_3               || gc_delim_pipe ||
            a.change_type         || gc_delim_pipe ||
            a.column_name         || gc_delim_pipe ||
            a.old_value           || gc_delim_pipe ||
            a.new_value
          from 
            data_compr_report a
          where
            a.config_id = i_config_rec.config_id
          order by
            case a.is_header
              when 'Y' then 0
              else          1
            end,
            a.key_1,
            a.key_2,
            a.key_3;
    loop
      fetch l_rc bulk collect into l_aa_rows limit l_limit;
      exit when l_aa_rows.count = 0;
      for i IN 1..l_aa_rows.count loop
        utl_file.put_line(l_file, l_aa_rows(i));
      end loop;
    end loop;
    
    close l_rc;
    utl_file.fclose(l_file);
  end prc_generate_file;

  procedure prc_main(
    i_src_table_name    data_compr_config.src_table_name%type
    ,i_trg_table_name   data_compr_config.trg_table_name%type
    ,i_key_1            data_compr_config.key_1%type
    ,i_key_2            data_compr_config.key_2%type default null
    ,i_key_3            data_compr_config.key_3%type default null
  )
  is
    l_proc_name         data_compr_log.proc_name%type := 'prc_main';
  begin
    prc_init(
      i_src_table_name      => i_src_table_name 
      ,i_trg_table_name     => i_trg_table_name 
      ,i_key_1              => i_key_1
      ,i_key_2              => i_key_2
      ,i_key_3              => i_key_3
    );

    prc_process_data;
    commit;
  end prc_main;
  
  procedure prc_main(
    i_config_id             data_compr_config.config_id%type
    ,i_generate_files       boolean default false
  )
  is
    l_proc_name             data_compr_log.proc_name%type := 'prc_main';
    l_config_rec            data_compr_config%rowtype;
    l_template              data_compr_template.template_val%type;
    cursor cur_config
    is
    select *
      from data_compr_config
     where config_id = i_config_id;
  begin
    open cur_config;
    
    fetch cur_config
     into l_config_rec;
     
    if l_config_rec.config_id is not null then
      g_config_id := l_config_rec.config_id;
      
      
      l_template := get_extn_table_template(
        i_template_id => l_config_rec.template_id
      );
      
      prc_create_ext_tables(
        i_config_rec        => l_config_rec
        ,i_template          => l_template
      );
      
      prc_main(
        i_src_table_name    => l_config_rec.src_table_name
        ,i_trg_table_name   => l_config_rec.trg_table_name
        ,i_key_1            => l_config_rec.key_1
        ,i_key_2            => l_config_rec.key_2
        ,i_key_3            => l_config_rec.key_3
      );
      
      if i_generate_files then
        prc_generate_file (
          i_config_rec      => l_config_rec
        );
      end if;
    else
      raise_application_error (-20002, ex_config_not_found_msg);
    end if;
    close cur_config;
  end prc_main;

  procedure prc_main(
    i_src_data_group            data_compr_config.src_data_group%type
    ,i_trg_data_group           data_compr_config.trg_data_group%type
    ,i_generate_files           boolean
  )
  is
    l_proc_name                 data_compr_log.proc_name%type := 'prc_main';
    l_config_cnt_failure        number := 0;
    l_config_cnt_success        number := 0;
  begin
    execute immediate 'truncate table data_compr_log';
    prc_write_log(i_log_type => 'I'
      ,i_message => 'Starting Data Comparision...'
      ,i_parameter_list => 'Source Date Group: ' || i_src_data_group || ' :: Target Data Group: '|| i_trg_data_group
      ,i_proc_name => l_proc_name
    );

    for rec in (select *
                  from data_compr_config
                 where src_data_group = i_src_data_group
                   and trg_data_group = i_trg_data_group) loop
      begin
        prc_main(
          i_config_id           => rec.config_id
          ,i_generate_files     => i_generate_files
        );

        l_config_cnt_success := l_config_cnt_success + 1;
      exception
        when others then
          l_config_cnt_failure := l_config_cnt_failure + 1;
          prc_write_log(
            i_log_type => 'E'
            ,i_message => 'Process failure while finding differences'
            ,i_parameter_list => 'Config_Id: ' || to_char(rec.config_id)
            ,i_proc_name => l_proc_name
          );
      end;
    end loop;
    if ((l_config_cnt_success + l_config_cnt_failure) = 0) then
      raise_application_error (-20002, ex_config_not_found_msg);
    else
      if (l_config_cnt_failure > 0) then
        prc_write_log(
          i_log_type => 'W'
          ,i_message => to_char(l_config_cnt_failure) || ' out of ' || to_char(l_config_cnt_success + l_config_cnt_failure) || ' configurations failed'
          ,i_parameter_list => null
            ,i_proc_name => l_proc_name
        );
      else
        prc_write_log(
          i_log_type => 'I'
          ,i_message => to_char(l_config_cnt_success) || ' out of ' || to_char(l_config_cnt_success + l_config_cnt_failure) || ' configurations processed successfully'
          ,i_parameter_list => null
          ,i_proc_name => l_proc_name
        );
      end if;
    end if;
  exception
    when ex_config_not_found then
        prc_write_log(
          i_log_type => 'E'
          ,i_message => 'Configuration Issue...'
          ,i_parameter_list => 'Source Date Group: ' || i_src_data_group || ' :: Target Data Group: '|| i_trg_data_group
          ,i_proc_name => l_proc_name
        );
      raise_application_error(-20001, ex_config_not_found_msg);
    when others then
        prc_write_log(
          i_log_type => 'F'
          ,i_message => 'Fatal error, process failed...'
          ,i_parameter_list => 'Source Date Group: ' || i_src_data_group || ' :: Target Data Group: '|| i_trg_data_group
          ,i_proc_name => l_proc_name
        );
      raise;
  end prc_main;

  procedure prc_add_template(
    i_template_val              data_compr_template.template_val%type,
    i_template_desc             data_compr_template.template_desc%type
  )
  is
    l_proc_name                 data_compr_log.proc_name%type := 'prc_add_template';
  begin
    insert into data_compr_template(
      template_id
      ,template_val
      ,template_desc
      ,created_at
      ,updated_at
    )
    values(
      data_compr_template_seq.nextval
      ,i_template_val
      ,i_template_desc
      ,SYSDATE
      ,null
    );

    commit;
  end prc_add_template;
  
  function get_template_id(
    i_template_desc             data_compr_template.template_desc%type
  ) return number
  is
    l_proc_name                 data_compr_log.proc_name%type := 'get_template_id';
    l_template_id               data_compr_template.template_id%type;
    cursor cur_template
    is
    select template_id
      from data_compr_template
     where template_desc = i_template_desc;
  begin
    open cur_template;
    
    fetch cur_template
     into l_template_id;
     
    close cur_template;
    
    if l_template_id is not null then
      return l_template_id;
    else
      raise_application_error(-20001, ex_template_not_found_msg);
    end if;
  end get_template_id;
  
  procedure prc_add_config(
    i_src_table_name     data_compr_config.src_table_name%type
    ,i_trg_table_name    data_compr_config.trg_table_name%type
    ,i_src_file_name     data_compr_config.src_file_name%type
    ,i_src_file_dir      data_compr_config.src_file_dir%type
    ,i_trg_file_name     data_compr_config.trg_file_name%type
    ,i_trg_file_dir      data_compr_config.trg_file_dir%type
    ,i_key_1             data_compr_config.key_1%type
    ,i_key_2             data_compr_config.key_2%type
    ,i_key_3             data_compr_config.key_3%type
    ,i_src_data_group    data_compr_config.src_data_group%type
    ,i_trg_data_group    data_compr_config.trg_data_group%type
    ,i_template_id       data_compr_config.template_id%type default null
  )
  is
    l_proc_name          data_compr_log.proc_name%type := 'prc_add_config';
    l_config_id          data_compr_config.config_id%type
      := case i_src_table_name
          when 'DUMMY_SRC' then
            -100
          else
            data_compr_config_seq.nextval
        end; 
    l_template_id        data_compr_template.template_id%type
      := nvl(i_template_id, get_template_id(replace(i_src_file_name, '_' || lower(i_src_data_group), '')));
  begin
    insert into data_compr_config(
      config_id
      ,src_table_name
      ,trg_table_name
      ,template_id
      ,src_file_name
      ,src_file_dir
      ,trg_file_name
      ,trg_file_dir
      ,key_1
      ,key_2
      ,key_3
      ,src_data_group
      ,trg_data_group
      ,created_at
      ,updated_at
    )
    values(
      l_config_id
      ,i_src_table_name
      ,i_trg_table_name
      ,l_template_id
      ,i_src_file_name
      ,i_src_file_dir
      ,i_trg_file_name
      ,i_trg_file_dir
      ,i_key_1
      ,i_key_2
      ,i_key_3
      ,i_src_data_group
      ,i_trg_data_group
      ,sysdate
      ,null
    );

    commit;
  end prc_add_config;

  procedure prc_add_excl_col(
    i_config_id          data_compr_excl_col.config_id%type
    ,i_column_name       data_compr_excl_col.column_name%type
  )
  is
    l_proc_name          data_compr_log.proc_name%type := 'prc_add_excl_col';
  begin
    insert into data_compr_excl_col(
      excl_col_id
      ,config_id
      ,column_name
      ,created_at
      ,updated_at
    )
    values(
      data_compr_excl_col_seq.nextval
      ,i_config_id
      ,upper(i_column_name)
      ,sysdate
      ,null
    );
    
    commit;
  end prc_add_excl_col;
  
  procedure prc_add_excl_col(
    i_src_table_name     data_compr_config.src_table_name%type
    ,i_column_name       data_compr_excl_col.column_name%type
  )
  is
    l_proc_name          data_compr_log.proc_name%type := 'prc_add_excl_col';
    l_config_id          data_compr_excl_col.config_id%type;
    cursor cur_config
    is
    select config_id
    from data_compr_config a
    where a.src_table_name = i_src_table_name
      and a.src_data_group = gc_sdg_data01
      and a.trg_data_group = gc_sdg_data02;
  begin
    open cur_config;
    
    fetch cur_config
    into  l_config_id;
    
    close cur_config;
    
    if (l_config_id is not null) then
      prc_add_excl_col(
        i_config_id         => l_config_id
        ,i_column_name      => i_column_name
      );
    else
      raise_application_error(-20002, ex_config_not_found_msg);
    end if;
  end prc_add_excl_col;
  
  procedure prc_clone_config(
    i_src_data_group     data_compr_config.src_data_group%type
    ,i_trg_data_group    data_compr_config.trg_data_group%type
  )
  is
    l_proc_name          data_compr_log.proc_name%type := 'prc_clone_config';
    l_rec_count           number := 0;
  begin
    delete data_compr_report a
     where a.config_id IN (select b.config_id
                           from data_compr_config b
                          where b.src_data_group = i_src_data_group
                            and b.trg_data_group = i_trg_data_group);

    delete data_compr_excl_col a
     where a.config_id IN (select b.config_id
                           from data_compr_config b
                          where b.src_data_group = i_src_data_group
                            and b.trg_data_group = i_trg_data_group);

    prc_write_log(
      i_log_type => 'I'
      ,i_message => 'data_compr_excl_col: ' || sql%rowcount || ' records deleted...'
      ,i_parameter_list => 'i_src_data_group > ' || i_src_data_group || ' :: i_trg_data_group ' || i_trg_data_group
      ,i_proc_name => l_proc_name
    );

    delete data_compr_config a
     where a.src_data_group = i_src_data_group
       and a.trg_data_group = i_trg_data_group;

    prc_write_log(
      i_log_type => 'I'
      ,i_message => 'data_compr_config: ' || sql%rowcount || ' records deleted...'
      ,i_parameter_list => null
      ,i_proc_name => l_proc_name
    );
            
    for rec in (select *
                  from data_compr_config
                 where src_data_group = gc_sdg_data01
                   and trg_data_group = gc_sdg_data02) loop
      prc_add_config(
        i_src_table_name     => rec.src_table_name
        ,i_trg_table_name    => rec.trg_table_name
        ,i_src_file_name     => replace(rec.src_file_name, lower(gc_sdg_data01), lower(i_src_data_group))
        ,i_src_file_dir      => rec.src_file_dir
        ,i_trg_file_name     => replace(rec.trg_file_name, lower(gc_sdg_data02), lower(i_trg_data_group))
        ,i_trg_file_dir      => rec.trg_file_dir
        ,i_key_1             => rec.key_1
        ,i_key_2             => rec.key_2
        ,i_key_3             => rec.key_3
        ,i_src_data_group    => upper(i_src_data_group)
        ,i_trg_data_group    => upper(i_trg_data_group)
        ,i_template_id       => rec.template_id
      );
      l_rec_count := l_rec_count + 1;
      
      insert into data_compr_excl_col(
        excl_col_id
        ,config_id
        ,column_name
        ,created_at
        ,updated_at
      )
      select
        data_compr_excl_col_seq.nextval
        ,data_compr_config_seq.currval
        ,a.column_name 
        ,sysdate
        ,null
      from data_compr_excl_col a
      where a.config_id IN (select b.config_id
                          from  data_compr_config b
                          where b.src_data_group = gc_sdg_data01
                          and   b.trg_data_group = gc_sdg_data02
                          and   b.config_id = rec.config_id);

      prc_write_log(
        i_log_type => 'I'
        ,i_message => 'data_compr_excl_col: ' || sql%rowcount || ' record(s) added...'
        ,i_parameter_list => null
        ,i_proc_name => l_proc_name
      );
    end loop;
    prc_write_log(
      i_log_type => 'I'
      ,i_message => 'data_compr_config: ' || to_char(l_rec_count) || ' record(s) added...'
      ,i_parameter_list => null
      ,i_proc_name => l_proc_name
    );
    commit;
  end prc_clone_config;

end data_compr;
/
