alter session set current_schema=parasan;

-- Create Test Data
exec drop_table('TBL_CHILD', user);

exec drop_table('TBL_PARENT', user);

exec drop_table('TBL_ADDRESS', user);

create table tbl_address
(address_id number not null,
 address_1  varchar2(100),
 address_2  varchar2(100),
 suburb     varchar2(100),
 state      varchar2(20),
 constraint tbl_address_pk
 primary key (address_id)
);

create table tbl_parent
(parent_id     number not null,
 address_id     number not null,
 parent_name   varchar2(100),
 parent_gender varchar2(1),
 constraint tbl_parent_pk
 primary key(parent_id),
 constraint tbl_parent_fk1
 foreign key (address_id) references tbl_address(address_id)
);

create table tbl_child
(child_id  number not null,
 parent_id number not null,
 address_id number not null,
 child_name varchar2(100),
 constraint tbl_child_pk
 primary key (child_id),
 constraint tbl_child_fk1
 foreign key (parent_id) references tbl_parent(parent_id),
 constraint tbl_child_fk2
 foreign key (address_id) references tbl_address(address_id)
);

insert into tbl_address
select level,
       'ADDRESS_1_' || to_char(level),
       'ADDRESS_2_' || to_char(level),
       'SUBURB_'    || to_char(mod(level, 5)),
       'STATE_'     || to_char(mod(level, 2))
  from dual
connect by level <= 20;

insert into tbl_parent
select level,
       mod(level ,20) + 1,
       'PARENT_NAME_' || to_char(level),
       decode(trunc(dbms_random.value(0,3)),0,'M', 1, 'F','U')
  from dual
connect by level <=50;

insert into tbl_child
select level,
       mod(level ,50) + 1,
       mod(level ,20) + 1,
       'CHILD_NAME_' || to_char(level)
  from dual
connect by level <=500;

commit;

-- Export Data
declare
  l_dp_handle       number;
begin
  l_dp_handle := dbms_datapump.open(
    operation   => 'EXPORT',
    job_mode    => 'SCHEMA',
    job_name    => 'TEST_EXPORT_1');

  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => 'test.dmp',
    directory => 'DATA_DIR',
    filetype  => DBMS_DATAPUMP.ku$_file_type_dump_file,
    reusefile => 1);

  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => 'test_exp.log',
    directory => 'DATA_DIR',
    filetype  => dbms_datapump.ku$_file_type_log_file);

  dbms_datapump.metadata_filter(
    handle => l_dp_handle,
    name   => 'SCHEMA_LIST',
    value  => q'|'PARASAN'|' );
    
  dbms_datapump.metadata_filter(
    handle => l_dp_handle,
    name   => 'NAME_EXPR',
    value  =>  q'|in ('TBL_ADDRESS','TBL_CHILD', 'TBL_PARENT')|',
    object_path=> 'TABLE' );
    
  dbms_datapump.set_parameter(
    handle => l_dp_handle,
    name   => 'INCLUDE_METADATA',
    value  => 0);

  dbms_datapump.start_job(l_dp_handle);

  dbms_datapump.detach(l_dp_handle);
end;
/

-- Run in a separate session

insert into tbl_address
values (21, 'ADDRESS_1_21', 'ADDRESS_2_22', 'SUBURB_3', 'STATE_0');

insert into tbl_parent
values (51, 21, 'PARENT_NAME_51', 'F');

insert into tbl_child
values (501, 51, 21, 'CHILD_NAME_501');

commit;

-- Disable FK/PK Constraints
alter table tbl_child disable constraint tbl_child_fk1;
alter table tbl_child disable constraint tbl_child_fk2;
alter table tbl_parent disable constraint tbl_parent_fk1;
alter table tbl_address disable constraint tbl_address_pk;
alter table tbl_parent disable constraint tbl_parent_pk;
alter table tbl_child disable constraint tbl_child_pk;

-- Import Data
declare
  l_dp_handle       number;
  l_status          varchar2(255);
  l_job_state       varchar2(4000);
  l_ku$status       ku$_status1020;
begin
  l_dp_handle := dbms_datapump.open(
    operation   => 'IMPORT',
    job_mode    => 'SCHEMA',
    job_name    => 'TEST_IMPORT_2');

  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => 'test.dmp',
    directory => 'DATA_DIR',
    filetype  => DBMS_DATAPUMP.ku$_file_type_dump_file);

  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => 'test_imp.log',
    directory => 'DATA_DIR',
    filetype  => dbms_datapump.ku$_file_type_log_file);

  dbms_datapump.set_parameter(
    handle    => l_dp_handle,
    name      => 'TABLE_EXISTS_ACTION',
    value     => 'REPLACE');
    
  dbms_datapump.set_parameter(
    handle    => l_dp_handle,
    name      => 'DATA_OPTIONS',
    value     => dbms_datapump.ku$_dataopt_skip_const_err);

  dbms_datapump.metadata_filter(
    handle      => l_dp_handle,
    name        => 'NAME_EXPR',
    value       =>  q'|in ('TBL_ADDRESS', 'TBL_PARENT')|',
    object_path => 'TABLE' );

  dbms_datapump.set_parameter(
    handle => l_dp_handle,
    name   => 'INCLUDE_METADATA',
    value  => 1);
  
  dbms_datapump.start_job(l_dp_handle);
  
  while true loop
    dbms_datapump.wait_for_job(handle => l_dp_handle,job_state => l_status);
    if l_status in ('COMPLETED', 'STOPPED') then
      exit;
    end if;
    dbms_datapump.get_status(
      handle    => l_dp_handle,
      mask      => dbms_datapump.ku$_status_job_error,
      job_state => l_job_state,
      status    => l_ku$status);
      
    dbms_output.put_line('State: ' || l_job_state);

    if l_ku$status.error is not null and l_ku$status.error.count > 0 then
      for i in l_ku$status.error.first .. l_ku$status.error.last loop
        dbms_output.put_line(l_ku$status.error(i).logtext);
      end loop;
    end if;
  end loop;
  dbms_datapump.detach(l_dp_handle);
end;
/

-- Disable FK/PK Constraints
alter table tbl_address enable constraint tbl_address_pk;
alter table tbl_parent enable constraint tbl_parent_pk;
alter table tbl_child enable constraint tbl_child_pk;
alter table tbl_child enable constraint tbl_child_fk1;
alter table tbl_child enable constraint tbl_child_fk2;
alter table tbl_parent enable constraint tbl_parent_fk1;


