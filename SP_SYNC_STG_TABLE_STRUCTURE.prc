CREATE OR REPLACE PROCEDURE SP_SYNC_STG_TABLE_STRUCTURE(
    V_SCHEMA_CORE_NAME IN VARCHAR2,
    V_CORE_TABLE_NAME IN VARCHAR2,
    V_SCHEMA_STG_NAME IN VARCHAR2,
    V_STG_TABLE_NAME IN VARCHAR2)
AS
  CURSOR C1 IS
     SELECT CORE_ATC.TABLE_NAME CORE_TAB_NAME,
            CORE_ATC.COLUMN_NAME CORE_COL_NAME,
            CORE_ATC.DATA_TYPE CORE_DATA_TYPE,
            CORE_ATC.DATA_LENGTH CORE_DATA_LENGTH,
            STG_ATC.DATA_TYPE STG_DATA_TYPE,
            STG_ATC.DATA_LENGTH STG_DATA_LENGTH,
            CASE 
                WHEN STG_ATC.COLUMN_NAME IS NULL THEN 1  -- Column added
                WHEN CORE_ATC.DATA_TYPE <> STG_ATC.DATA_TYPE OR CORE_ATC.DATA_LENGTH <> STG_ATC.DATA_LENGTH THEN 2  -- Data type or length changed
                ELSE 0
            END AS FLAG
     FROM ALL_TAB_COLS CORE_ATC
     LEFT JOIN ALL_TAB_COLS STG_ATC ON STG_ATC.COLUMN_NAME = CORE_ATC.COLUMN_NAME
          AND STG_ATC.TABLE_NAME = UPPER(V_STG_TABLE_NAME)
          AND STG_ATC.OWNER = UPPER(V_SCHEMA_STG_NAME)
     WHERE CORE_ATC.TABLE_NAME = UPPER(V_CORE_TABLE_NAME)
       AND CORE_ATC.OWNER = UPPER(V_SCHEMA_CORE_NAME)
       
       AND (STG_ATC.COLUMN_NAME IS NULL OR CORE_ATC.DATA_TYPE <> STG_ATC.DATA_TYPE OR CORE_ATC.DATA_LENGTH <> STG_ATC.DATA_LENGTH);

BEGIN
    FOR REC IN C1 LOOP
        BEGIN
            IF REC.FLAG = 1 THEN
                -- Column added
                EXECUTE IMMEDIATE 'ALTER TABLE ' || V_STG_TABLE_NAME || ' ADD ' || REC.CORE_COL_NAME || ' ' || REC.CORE_DATA_TYPE ||
                    CASE 
                        WHEN REC.CORE_DATA_TYPE IN ('VARCHAR2', 'CHAR') THEN '(' || REC.CORE_DATA_LENGTH || ')'
                        ELSE ''
                    END;
            ELSIF REC.FLAG = 2 THEN
                -- Data type or length changed
                EXECUTE IMMEDIATE 'ALTER TABLE ' || V_STG_TABLE_NAME || ' MODIFY ' || REC.CORE_COL_NAME || ' ' || REC.CORE_DATA_TYPE ||
                    CASE 
                        WHEN REC.CORE_DATA_TYPE IN ('VARCHAR2', 'CHAR') THEN '(' || REC.CORE_DATA_LENGTH || ')'
                        ELSE ''
                    END;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error altering table structure: ' || SQLERRM);
        END;

        -- Insert change log
        BEGIN
            INSERT INTO TBL_STG_STRUCTURE_CHANGE_LOG(
                CORE_TABLE_NAME,
                COLUMN_NAME,
                CORE_DATA_TYPE,
                CORE_DATA_LENGTH,
                STG_DATA_TYPE,          
                STG_DATA_LENGTH,
                CHANGE_DATE
            ) VALUES (
                REC.CORE_TAB_NAME,
                REC.CORE_COL_NAME,
                REC.CORE_DATA_TYPE,
                REC.CORE_DATA_LENGTH,
                REC.STG_DATA_TYPE,          
                REC.STG_DATA_LENGTH,
                SYSDATE
            );
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inserting into change log: ' || SQLERRM);
        END;
    END LOOP;

    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error in SP_SYNC_STG_TABLE_STRUCTURE: ' || SQLERRM);
END SP_SYNC_STG_TABLE_STRUCTURE;

