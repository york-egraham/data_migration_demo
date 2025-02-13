
-- Author: Ethan Graham
-- Procedure to compare 2 tables and return 1 if they have all the same rows and data in those rows.

CREATE OR REPLACE PROCEDURE compare_output_tables (
    p_actual_table   IN VARCHAR2,
    p_expected_table IN VARCHAR2,
    p_result         OUT NUMBER  -- Returns 1 if matched, 0 if mismatch
) AS
    v_count NUMBER;
    v_sql   VARCHAR2(4000);
BEGIN
    -- Build the dynamic SQL query that compares the two tables
    -- (A - B) U (B - A)
    v_sql := 'SELECT COUNT(*) FROM ( ' ||
             '  (SELECT * FROM ' || p_actual_table || ' MINUS SELECT * FROM ' || p_expected_table || ') ' ||
             '  UNION ALL ' ||
             '  (SELECT * FROM ' || p_expected_table || ' MINUS SELECT * FROM ' || p_actual_table || ') ' ||
             ')';

    -- Execute the dynamic SQL and get the count of differences
EXECUTE IMMEDIATE v_sql INTO v_count;

-- If no differences, return 1 (Match); otherwise, return 0 (Mismatch)
IF v_count = 0 THEN
        p_result := 1;
ELSE
        p_result := 0;
END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
/