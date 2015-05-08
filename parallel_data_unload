CREATE TYPE unload_ot
AS OBJECT (file_name  VARCHAR2(128),
           no_records NUMBER,
           session_id NUMBER );
/

CREATE TYPE unload_ntt AS TABLE OF unload_ot;
/

CREATE OR REPLACE PACKAGE pk_unloader
AS
   c_default_limit CONSTANT PLS_INTEGER := 100;

   PROCEDURE prc_unload_data_v1 (p_source     IN SYS_REFCURSOR,
                                 p_file_name  IN VARCHAR2,
                                 p_directory  IN VARCHAR2,
                                 p_limit_size IN PLS_INTEGER DEFAULT pk_unloader.c_default_limit);

   FUNCTION fun_unload_data_v2 (p_source      IN SYS_REFCURSOR,
                                p_file_name   IN VARCHAR2,
                                p_directory   IN VARCHAR2,
                                p_limit_size IN PLS_INTEGER DEFAULT pk_unloader.c_default_limit)
   RETURN unload_ntt
   PIPELINED PARALLEL_ENABLE (PARTITION p_source BY ANY);
   
   FUNCTION fun_unload_data_v3 (p_source      IN SYS_REFCURSOR,
                                p_file_name   IN VARCHAR2,
                                p_directory   IN VARCHAR2,
                                p_limit_size IN PLS_INTEGER DEFAULT pk_unloader.c_default_limit)
   RETURN unload_ntt
   PIPELINED PARALLEL_ENABLE (PARTITION p_source BY ANY);

END pk_unloader;
/

CREATE OR REPLACE PACKAGE BODY pk_unloader
AS

   SUBTYPE st_maxline IS VARCHAR2(32767);
   c_maxline CONSTANT PLS_INTEGER := 32767;

   TYPE row_aat IS TABLE OF st_maxline
                   INDEX BY PLS_INTEGER;
   
   PROCEDURE prc_unload_data_v1 (p_source     IN SYS_REFCURSOR,
                                 p_file_name  IN VARCHAR2,
                                 p_directory  IN VARCHAR2,
                                 p_limit_size IN PLS_INTEGER DEFAULT pk_unloader.c_default_limit)
   IS
      aa_rows   row_aat;
      v_file    UTL_FILE.FILE_TYPE;
   BEGIN
      v_file := UTL_FILE.FOPEN(p_directory, p_file_name, 'w');
      LOOP
         FETCH p_source BULK COLLECT INTO aa_rows LIMIT p_limit_size;
         EXIT WHEN aa_rows.COUNT = 0;
         FOR i IN 1..aa_rows.COUNT LOOP
            UTL_FILE.PUT_LINE(v_file, aa_rows(i));
         END LOOP;
      END LOOP;
      
      CLOSE p_source;
      UTL_FILE.FCLOSE(v_file);
   END prc_unload_data_v1;
   
   FUNCTION fun_unload_data_v2 (p_source      IN SYS_REFCURSOR,
                                p_file_name   IN VARCHAR2,
                                p_directory   IN VARCHAR2,
                                p_limit_size IN PLS_INTEGER DEFAULT pk_unloader.c_default_limit)
   RETURN unload_ntt
   PIPELINED PARALLEL_ENABLE (PARTITION p_source BY ANY)
   IS
      aa_rows   row_aat;
      v_sid     NUMBER := SYS_CONTEXT('USERENV', 'SID');
      v_name    VARCHAR2(128) := p_file_name || '_' || v_sid || '.txt';
      v_file    UTL_FILE.FILE_TYPE;
      v_lines   PLS_INTEGER;
   BEGIN
      v_file := UTL_FILE.FOPEN(p_directory, v_name, 'w', c_maxline);
      LOOP
         FETCH p_source BULK COLLECT INTO aa_rows LIMIT p_limit_size;
         EXIT WHEN aa_rows.COUNT = 0;
         FOR i IN 1 .. aa_rows.COUNT LOOP
            UTL_FILE.PUT_LINE(v_file, aa_rows(i));
         END LOOP;
      END LOOP;
      v_lines := p_source%ROWCOUNT;
      
      CLOSE p_source;
      UTL_FILE.FCLOSE(v_file);
      PIPE ROW (unload_ot(v_name, v_lines, v_sid));
      RETURN;   
   
   END fun_unload_data_v2;

   FUNCTION fun_unload_data_v3 (p_source      IN SYS_REFCURSOR,
                                p_file_name   IN VARCHAR2,
                                p_directory   IN VARCHAR2,
                                p_limit_size IN PLS_INTEGER DEFAULT pk_unloader.c_default_limit)
   RETURN unload_ntt
   PIPELINED PARALLEL_ENABLE (PARTITION p_source BY ANY)
   IS
      c_eol     CONSTANT VARCHAR2(1) := CHR(10);
      aa_rows   row_aat;
      v_buffer  VARCHAR2(32767);
      v_sid     NUMBER := SYS_CONTEXT('USERENV', 'SID');
      v_name    VARCHAR2(128) := p_file_name || '_' || v_sid || '.txt';
      v_file    UTL_FILE.FILE_TYPE;
      v_lines   PLS_INTEGER;
   BEGIN
      v_file := UTL_FILE.FOPEN(p_directory, v_name, 'w', c_maxline);
      LOOP
         FETCH p_source BULK COLLECT INTO aa_rows LIMIT p_limit_size;
         EXIT WHEN aa_rows.COUNT = 0;
         FOR i IN 1 .. aa_rows.COUNT LOOP
            IF LENGTH(v_buffer) + 1 + LENGTH(aa_rows(i)) <= c_maxline THEN
               v_buffer := v_buffer || c_eol || aa_rows(i);
            ELSE
               IF v_buffer IS NOT NULL THEN
                  UTL_FILE.PUT_LINE(v_file, v_buffer);
               END IF;
               v_buffer := aa_rows(i);
            END IF;
         END LOOP;
      END LOOP;
      UTL_FILE.PUT_LINE(v_file, v_buffer);
      v_lines := p_source%ROWCOUNT;
      
      CLOSE p_source;
      UTL_FILE.FCLOSE(v_file);
      PIPE ROW (unload_ot(v_name, v_lines, v_sid));
      RETURN;   
   
   END fun_unload_data_v3;

END pk_unloader;
/

SHO ERR

DECLARE
   v_start_time NUMBER := DBMS_UTILITY.get_time;
   v_end_time  NUMBER;
   v_rc  SYS_REFCURSOR;

BEGIN
   OPEN v_rc 
    FOR SELECT counterparty_id           || '|' ||
               counterparty_name         || '|' ||
               counterparty_short_name   || '|' ||
               counterparty_name         || '|' ||
               parent_counterparty_id    || '|' ||
               counterparty_group_id     || '|' ||
               counterparty_group_name   || '|' ||
               country_of_operation_name || '|' ||
               bta_name_of_accounts      || '|' ||
               bic_description
          FROM counterparty t;
                                                    
   pk_unloader.prc_unload_data_v1(p_source    => v_rc,
                                  p_file_name => 'COUNTERPARTY_OUT.txt',
                                  p_directory => 'DIR');
   v_end_time := DBMS_UTILITY.get_time;
   DBMS_OUTPUT.PUT_LINE('Total time Taken:' || TO_CHAR((v_end_time - v_start_time) /100));
END;
/

SELECT *
  FROM TABLE (pk_unloader.fun_unload_data_v2 
      (p_source => CURSOR (SELECT /*+ PARALLEL(t, 4) */
                                  counterparty_id
                                  || '|'
                                  || counterparty_name
                                  || '|'
                                  || counterparty_short_name
                                  || '|'
                                  || counterparty_name
                                  || '|'
                                  || parent_counterparty_id
                                  || '|'
                                  || counterparty_group_id
                                  || '|'
                                  || counterparty_group_name
                                  || '|'
                                  || country_of_operation_name
                                  || '|'
                                  || bta_name_of_accounts
                                  || '|'
                                  || bic_description
                             FROM counterparty t),
       p_file_name => 'COUNTERPARTY_OUT',
       p_directory => 'DIR'))
/


SELECT *
  FROM TABLE (pk_unloader.fun_unload_data_v3 
      (p_source => CURSOR (SELECT /*+ PARALLEL(t, 4) */
                                  counterparty_id
                                  || '|'
                                  || counterparty_name
                                  || '|'
                                  || counterparty_short_name
                                  || '|'
                                  || counterparty_name
                                  || '|'
                                  || parent_counterparty_id
                                  || '|'
                                  || counterparty_group_id
                                  || '|'
                                  || counterparty_group_name
                                  || '|'
                                  || country_of_operation_name
                                  || '|'
                                  || bta_name_of_accounts
                                  || '|'
                                  || bic_description
                             FROM counterparty t),
       p_file_name => 'COUNTERPARTY_OUT',
       p_directory => 'DIR'))
/
