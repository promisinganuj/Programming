drop table ext_applicants
/

create table ext_applicants (
  applicant_id        number
  ,first_name         varchar2(40 char)
  ,last_name          varchar2(40 char)
  ,user_name          varchar2(85 char)
  ,date_of_birth      date
  ,resume_cv          clob
  ,applicant_type     varchar2(50 char)
  ,update_date        date
)
organization external(
  type oracle_loader
  default directory db_file_dir
  access parameters (
    records delimited by newline
    badfile db_file_dir:'applicants_%a_%p.bad'
    logfile db_file_dir:'applicants_%a_%p.log'
    skip 1
    load when date_of_birth != blanks
    load when (1:4) != '<END'
    fields terminated by '|'
    optionally enclosed by '"'
    missing field values are null
    (  applicant_id
      ,first_name
      ,last_name
      ,date_of_birth    char(10) date_format date mask "YYYY-MM-DD"
      ,resume
    )
    column transforms
    (
      user_name       from concat(first_name, constant '.' , last_name)
      ,resume_cv      from lobfile(resume) from (db_file_dir)  clob
      ,update_date    from null
      ,applicant_type from constant 'GRADUATE'
    )
  )
    location ('applicants.txt')
)
reject limit unlimited
/
