##DATABASE UTILITY

Configuration based oracle database utility to compare delimited files with similar structures and producing difference report.

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
* Change to the directory where the shell script is saved: Ex: "cd /home/oracle/scripts"
* Copy the files to the Oracle directory:
  The shell script takes 3 parameters: "the drop information", "the date in the drop folder corresponding to the drop" and "Target Oracle Directory"
  `copy_files.ksh drop3 20160319 files_dir`
  `copy_files.ksh drop4 20160320 files_dir`

            With this, the files would be copied to "/u01/app/oracle/admin/avamig04/aaa/io/migrt_diff" directory with drop info appended to their names.
Install Database Code (One time activity, already done on AVAMIG04): SQLPLUS>@install_data_compr_util.sql
Clone configuration: SQLPLUS>exec cre$migrt_data_compr#.prc_clone_config('DROP20', 'DROP24')
Create difference report: SQLPLUS> exec cre$migrt_data_compr#.prc_main(i_src_data_group  => 'DROP20' ,i_trg_data_group => 'DROP24',i_generate_files => true)
If you don't want to generate the output files but just want to compare the result in DB, pass "i_generate_files" as false.
This will find the differences and save them in "cre$migrt_data_compr_report" table corresponding to the "config_id". Also the diff files would be generated on UNIX:
For Ex:
Source File Name: soa_sent_drop20.txt
Target File Name: soa_sent_drop24.txt
Differ File Name: soa_sent_drop20_drop24_diff.txt
      oracle@nex-pro-phi-007:avamig04 > head soa_sent_drop20_drop24_diff.txt
REPORT_ID|CONFIG_ID|DATE_GENERATED|TABLE_NAME|KEY_1 (I_PORTF_NO)|KEY_2 (I_SOA_ID)|KEY_3 ()|CHANGE_TYPE|COLUMN_NAME|OLD_VALUE|NEW_VALUE
70420|30|08-Apr-2016|CRE$MIGRT_SOA_SENT_EXT_SRC|121|3434||ADDED|||
70421|30|08-Apr-2016|CRE$MIGRT_SOA_SENT_EXT_SRC|15|35476||ADDED|||
      ...
Assumptions / Restrictions / Features:
(R) The three files where a unique key can't be determined are excluded from the comparison.
(A) The maximum number of keys to determine a unique account can't exceed three.
(R) If the config is re-cloned, the previous data generated against the configuration is deleted. However the old UNIX diff files would still be there unless the comparison is rerun, after which they would be overwritten as well.
(F) Instead of running for src/trg combination, the utility can be run for single configuration:
​SQLPLUS>exec cre$migrt_data_compr#.prc_main(i_config_id => 1);
(F) The utility also supports adhoc comparison of tables with similar structure. For that no configuration is required:
SQLPLUS>exec cre$migrt_data_compr#.prc_main(i_src_table_name => '<SRC_TABLE_NAME>', i_trg_table_name => '<TRG_TABLE_NAME>', i_key_1 => '<KEY_1>', i_key_2 => '<KEY_2>', i_key_3 => '<KEY_3>');
(F) The debugging information is turned-off for normal run. It can be turned-on by executing the following proc:
​SQLPLUS>exec cre$migrt_data_compr#prc_set_debug(i_write_debug_info => true)
(F) The generated reports are saved in DB so it's possible to append delta reports for each subsequent runs.
(F) It's possible to exclude certain columns from comparison.
Next Steps:
I am improving the error handling and unit testing the code. Also, I am looking for the possibility to add the person Avaloq key for making it easier for ops team to key-in details in Avaloq.

Please have a look at it, feel free to give it a go and provide me your feedback.
