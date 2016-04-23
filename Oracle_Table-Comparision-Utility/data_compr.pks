create or replace package data_compr
is
  procedure prc_set_debug(
    i_write_debug_info    boolean
  );
  
  procedure prc_write_log(
    i_log_type            data_compr_log.log_type%type
    ,i_message            data_compr_log.log_message%type
    ,i_parameter_list     data_compr_log.parameters_list%type
    ,i_proc_name          data_compr_log.proc_name%type
  );

  procedure prc_main(
    i_config_id           data_compr_config.config_id%type
    ,i_generate_files     boolean default false
  );
  
  procedure prc_main(
    i_src_data_group      data_compr_config.src_data_group%type
    ,i_trg_data_group     data_compr_config.trg_data_group%type
    ,i_generate_files     boolean default false
  );
  
  procedure prc_main(
    i_src_table_name      data_compr_config.src_table_name%type
    ,i_trg_table_name     data_compr_config.trg_table_name%type
    ,i_key_1              data_compr_config.key_1%type
    ,i_key_2              data_compr_config.key_2%type default null
    ,i_key_3              data_compr_config.key_3%type default null
  );
  
  procedure prc_add_template(
    i_template_val       data_compr_template.template_val%type
    ,i_template_desc     data_compr_template.template_desc%type
  );
  
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
  );
  
  procedure prc_add_excl_col(
    i_config_id          data_compr_excl_col.config_id%type
    ,i_column_name       data_compr_excl_col.column_name%type
  );
  
  procedure prc_add_excl_col(
    i_src_table_name     data_compr_config.src_table_name%type
    ,i_column_name       data_compr_excl_col.column_name%type
  );
  
  procedure prc_clone_config(
    i_src_data_group     data_compr_config.src_data_group%type
    ,i_trg_data_group    data_compr_config.trg_data_group%type
  );

end data_compr;
/
