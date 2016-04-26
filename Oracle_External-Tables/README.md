### Oracle External Table
This is a simple illustration of external tables in Oracle. Every Oracle developer must have used external tables at some point of time including myself. However, each time I try to create external table for a specific requirement, it takes me a lot of time to get the syntax correct. This blog is written as a reference point to get the syntax right and avoiding common pitfalls, nothing more and nothing less. 

Let's get started by creating a simple external table called "ext_applicants" which would be used to read the applicant information.

```
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
````

select *
  from ext_applicants
/

Here is the content of different files:

[oracle@localhost Desktop]$ cat applicants.txt
"applicant_id"|"first_name"|"last_name"|"dob"|"resume"
"1000"|"first_name_1000"|"last_name_1000"|"1989-02-13"|"resume_1000.txt"
"2000"|"first_name_2000"|"last_name_2000"|"1991-05-31"|"resume_2000.csv"
"3000"|"first_name_3000"|"last_name_3000"||"resume_3000.txt"
"4000"|"first_name_4000"|"last_name_4000"|"1986-10-01"|"resume_4000.txt"
<END:4>

[oracle@localhost Desktop]$ cat resume_1000.txt
I am resume of application 1000
[oracle@localhost Desktop]$ cat resume_2000.csv
I am resume of application 2000
[oracle@localhost Desktop]$ cat resume_3000.txt
I am resume of application 3000
[oracle@localhost Desktop]$ cat resume_4000.txt
I am resume of application 4000

The following points should be noticed:
While creating an external table, especially using an IDE such as Toad or SQL-Developer, DON'T leave any line commented under the access parameters. For Ex: if 


