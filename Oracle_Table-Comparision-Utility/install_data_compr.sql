alter session set current_schema=&1
/

---- CREATE ORACLE DIRECTORY FOR INCOMING FILES ----
create or replace directory DB_DIR as '&2'
/

---- DROP OBJECTS ----
-- DROP SEQUENCES --
drop sequence data_compr_report_seq
/

drop sequence data_compr_config_seq
/

drop sequence data_compr_template_seq
/

drop sequence data_compr_excl_col_seq
/

drop sequence data_compr_log_seq
/

-- DROP TABLES --
drop table data_compr_report
/

drop table data_compr_excl_col
/

drop table data_compr_config
/

drop table data_compr_template
/

drop table data_compr_log
/

---- CREATE OBJECTS ----
-- CREATE SEQUENCES --
create sequence data_compr_report_seq
/

create sequence data_compr_config_seq
/

create sequence data_compr_template_seq
/

create sequence data_compr_excl_col_seq
/

create sequence data_compr_log_seq
/

-- CREATE TABLES --
create table data_compr_template
(
  template_id       number        not null
  ,template_val     clob          not null
  ,template_desc    varchar2(100) not null
  ,created_at       date default sysdate not null
  ,updated_at       date
  ,constraint data_compr_template#p#id primary key (template_id)
)
/

create table data_compr_config(
  config_id          number               not null
  ,src_table_name    varchar2(30)         not null
  ,trg_table_name    varchar2(30)         not null
  ,template_id       number               not null
  ,src_file_name     varchar2(100)        not null
  ,src_file_dir      varchar2(100)        not null
  ,trg_file_name     varchar2(100)        not null
  ,trg_file_dir      varchar2(100)        not null
  ,key_1             varchar2(100)        not null
  ,key_2             varchar2(100)
  ,key_3             varchar2(100)
  ,src_data_group    varchar2(100)        not null
  ,trg_data_group    varchar2(100)        not null
  ,created_at        date default sysdate not null
  ,updated_at        date
  ,constraint data_compr_config#p#id
    primary key (config_id)
  ,constraint data_compr_config#u#1
    unique (src_data_group, trg_data_group, config_id)
  ,constraint data_compr_config#f#1
    foreign key (template_id) references data_compr_template(template_id)
  ,constraint data_compr_config#c#1
    check (REGEXP_LIKE(src_data_group, 'DROP\d+'))
  ,constraint data_compr_config#c#2
    check (REGEXP_LIKE(trg_data_group, 'DROP\d+'))
)
/

create table data_compr_excl_col
(
  excl_col_id        number               not null
  ,config_id         number               not null
  ,column_name       varchar2(30)         not null
  ,created_at        date default sysdate not null
  ,updated_at        date
  ,constraint data_compr_excl_col#p#id
    primary key (excl_col_id)
  ,constraint data_compr_excl_col#u#1
    unique (config_id, column_name, excl_col_id)
  ,constraint data_compr_excl_col#f#1
    foreign key (config_id) references data_compr_config(config_id)
)
/

create table data_compr_report(
  report_id        number                 not null
  ,config_id       number                 not null
  ,date_generated  varchar2(11)           not null
  ,src_table_name  varchar2(30)           not null
  ,key_1           varchar2(100)          not null
  ,key_2           varchar2(100)
  ,key_3           varchar2(100)
  ,change_type     varchar2(30)           not null
  ,column_name     varchar2(30)
  ,old_value       varchar2(4000)
  ,new_value       varchar2(4000)
  ,is_header       varchar2(1)            not null
  ,created_at      date default sysdate   not null
  ,updated_at      date
  ,constraint data_compr_report#p#id
    primary key (report_id)
  ,constraint data_compr_report#u#1
    unique (config_id, report_id)
  ,constraint data_compr_report#f#1
    foreign key (config_id) references data_compr_config(config_id)
  ,constraint data_compr_report#c#1
	check (is_header in ('Y', 'N'))
)
/

create table data_compr_log(
  log_id           number                 not null
  ,log_type        varchar2(7)	default 'INFO'		  not null
  ,proc_name       varchar2(65)           not null
  ,config_id       number                 not null
  ,log_message	   varchar2(4000)         not null
  ,parameters_list varchar2(4000)
  ,error_code      number
  ,error_message   varchar2(4000)
  ,error_backtrace varchar2(4000)
  ,log_timestamp   timestamp
  ,constraint data_compr_log#p#id
    primary key (log_id)
  ,constraint data_compr_log#c#1
	check (log_type in ('INFO', 'WARNING', 'ERROR', 'FATAL', 'DEBUG'))
)
/

-- CREATE INDEX --
create index data_compr_log#i#1
  on data_compr_log(config_id)
/

-- CREATE PACKAGE --
@data_compr.pks

@data_compr.pkb

---- INSERT STATIC CONFIGURATION ----

-- INSERT EXTERNAL TABLE TEMPLATES --

begin
  data_compr.prc_add_template(
    i_template_val   => empty_clob()
    ,i_template_desc => 'dummy_file.txt');
end;
/

begin
  data_compr.prc_add_template(
    TO_CLOB('create table <table_name>(
    COL1                          varchar2(4000)
    ,COL2                          varchar2(4000)
    ,COL3                          varchar2(4000)
  )
  organization external (
    type              oracle_loader
    default directory <db_dir>
    access parameters (
      records delimited  by newline
      skip    2
      load when (1:4) != ''<END''
      fields  terminated by ''|''
      missing field values are null
      (
        "COL1"
       ,"COL2"
       ,"COL3"
      )
    )
    location (''<file_name>'')
  )
  reject limit unlimited'),
  'file1_name.txt');
end;
/

begin
  data_compr.prc_add_template(
    TO_CLOB('create table <table_name>(
    COL1                          varchar2(4000)
    ,COL2                          varchar2(4000)
    ,COL3                          varchar2(4000)
    ,COL4                          varchar2(4000)
    ,COL5                          varchar2(4000)
  )
  organization external (
    type              oracle_loader
    default directory <db_dir>
    access parameters (
      records delimited  by newline
      skip    2
      load when (1:4) != ''<END''
      fields  terminated by ''|''
      missing field values are null
      (
        "COL1"
        ,"COL2"
        ,"COL3"
        ,"COL4"
        ,"COL5"
      )
    )
    location (''<file_name>'')
  )
  reject limit unlimited'),
  'file2_name.txt');
end;
/


-- INSERT MAIN CONFIGURATION --
begin
  data_compr.prc_add_config(
    i_src_table_name     => 'DUMMY_SRC'
    ,i_trg_table_name    => 'DUMMY_TRG'
    ,i_src_file_name     => 'dummy_file_drop00.txt'
    ,i_src_file_dir      => 'dummy_file_dir'
    ,i_trg_file_name     => 'dummy_file_drop00.txt'
    ,i_trg_file_dir      => 'dummy_file_dir'
    ,i_key_1             => 'dummy_key_1'
    ,i_key_2             => 'dummy_key_2'
    ,i_key_3             => 'dummy_key_3'
    ,i_src_data_group    => 'DROP00'
    ,i_trg_data_group    => 'DROP00'
  );
end;
/

begin
  data_compr.prc_add_config(
    i_src_table_name     => 'FILE1_NAME_EXT_SRC'
    ,i_trg_table_name    => 'FILE1_NAME_EXT_TRG'
    ,i_src_file_name     => 'file1_name_drop01.txt'
    ,i_src_file_dir      => 'DB_DIR'
    ,i_trg_file_name     => 'file1_name_drop02.txt'
    ,i_trg_file_dir      => 'DB_DIR'
    ,i_key_1             => 'COL1'
    ,i_key_2             => null
    ,i_key_3             => null
    ,i_src_data_group    => 'DROP01'
    ,i_trg_data_group    => 'DROP02'
  );
end;
/

begin
  data_compr.prc_add_config(
    i_src_table_name     => 'FILE2_NAME_EXT_SRC'
    ,i_trg_table_name    => 'FILE2_NAME_EXT_TRG'
    ,i_src_file_name     => 'file2_name_drop01.txt'
    ,i_src_file_dir      => 'DB_DIR'
    ,i_trg_file_name     => 'file2_name_drop02.txt'
    ,i_trg_file_dir      => 'DB_DIR'
    ,i_key_1             => 'COL1'
    ,i_key_2             => 'COL2'
    ,i_key_3             => null
    ,i_src_data_group    => 'DROP01'
    ,i_trg_data_group    => 'DROP02'
  );
end;
/

begin
  data_compr.prc_add_excl_col(
	i_src_table_name 	 => 'FILE2_NAME_EXT_SRC'
	,i_column_name		 => 'COL5'
  );
end;
/
