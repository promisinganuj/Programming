##Delimited File Comparision Utility

Configuration based oracle database utility to compare delimited files with similar structur and produce difference report.

###Main Components
* Table `data_compr_template`:  Table for storing the external table template
* Table `data_compr_config`: Main configuration table
* Table `data_compr_excl_col`: Table to exclude particular columns from comparison
* Table `data_compr_report`: Table to store the generated comparison results
* Table `data_compr_log`: Table to log execution/debug information
* Package `data_compr`: Package to create the config, clone config and create difference report
* Shell Script `copy_files.ksh`: Shell Script to copy files to Oracle directory

###Usage Steps
* Login to Oracle server with a user having required privileges

* Change to the directory where the shell script is saved:

  `cd /home/oracle/scripts`

* Copy the files to the Oracle directory:
  The shell script takes 3 parameters: "the drop information", "the date in the drop folder corresponding to the drop" and "Target Oracle Directory"

  `copy_files.ksh drop3 20160319 files_dir`
  
  `copy_files.ksh drop4 20160320 files_dir`

  With this, the files would be copied to `$base_dir/files_dir` directory with drop information appended to their names (`$base_dir` is 
  defined in the sheel script).

* Install Utility (One time activity):

  `SQLPLUS>@install_data_compr.sql "<schema_name>" "$BASE_DIR/files_dir"`

* Clone configuration:

  `SQLPLUS>exec data_compr.prc_clone_config('DROP3', 'DROP4');`
  
* Create difference report:
  ```
  SQLPLUS> exec data_compr.prc_main(i_src_data_group => 'DROP3'
                                    ,i_trg_data_group => 'DROP4'
                                    ,i_generate_files => true);
  ```
  
  If the output difference files are not required and only wants to compare the result in DB, pass `i_generate_files` as false.
  This will find the differences and save them in `data_compr_report` table corresponding to the `config_id`.
  Also the difference files would be generated on db server. For Ex:
  ```
  Source File Name: file1_drop3.txt
  Target File Name: file1_drop4.txt
  Differ File Name: file1_drop3_drop4_diff.txt
  oracle@server:demo > head file1_drop3_drop4_diff.txt
  REPORT_ID|CONFIG_ID|DATE_GENERATED|TABLE_NAME|KEY_1 (COL1)|KEY_2 ()|KEY_3 ()|CHANGE_TYPE|COLUMN_NAME|OLD_VALUE|NEW_VALUE
  420|30|08-Mar-2016|FILE1_NAME_EXT_SRC|14|||ADDED|||
  421|30|08-Mar-2016|FILE1_NAME_EXT_SRC|15|||UPDATED|COL3|OLD_VAL|NEW_VAL
  422|30|08-Mar-2016|FILE1_NAME_EXT_SRC|16|||DELETED|||
  ...
  ```
###Assumptions (A) / Restrictions (R) / Features (F):
* _(R)_ The files should have a unique key available for comparision.

* _(A)_ The maximum number of keys to determine a unique record is 3.

* _(R)_ If the configuration is re-cloned, the previous data generated against the configuration is deleted. However the old UNIX diff files would still be there unless the comparison is rerun, after which they would be overwritten as well.

* _(F)_ Instead of running for src/trg combination, the utility can be run for single configuration:

  `SQLPLUS>exec data_compr.prc_main(i_config_id => 1);`

* _(F)_ The utility also supports adhoc comparison of tables with similar structure. For that no configuration is required:
  ```
  SQLPLUS>exec data_compr.prc_main(i_src_table_name => '<SRC_TABLE_NAME>'
  
                                  ,i_trg_table_name => '<TRG_TABLE_NAME>'

                                  ,i_key_1          => '<KEY_1>'

                                  ,i_key_2          => '<KEY_2>'

                                  ,i_key_3          => '<KEY_3>');
  ```
* _(F)_ The debugging information is turned-off for normal run. It can be turned-on by executing the following proc:

  `SQLPLUS>exec data_compr.prc_set_debug(i_write_debug_info => true);`

* _(F)_ The generated reports are saved in DB so it's possible to append delta reports for each subsequent runs.
* _(F)_ It's possible to exclude certain columns from comparison.
