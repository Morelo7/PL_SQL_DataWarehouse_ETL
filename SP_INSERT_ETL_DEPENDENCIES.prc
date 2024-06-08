CREATE OR REPLACE PROCEDURE SP_INSERT_ETL_DEPENDENCIES(V_PROC_NAME IN VARCHAR2)
AS
  CURSOR C1 IS
    SELECT AD.OWNER,
           AD.NAME,
           AD.REFERENCED_OWNER,
           AD.REFERENCED_NAME        
    FROM ALL_DEPENDENCIES AD
    WHERE AD.NAME = UPPER(V_PROC_NAME)
      AND AD.REFERENCED_TYPE = 'TABLE';
BEGIN
  -- Start with deleting existing dependencies for the procedure
  DELETE FROM TBL_ETL_DEPENDENCIES T
  WHERE T.NAME = UPPER(V_PROC_NAME);

  -- Insert new dependencies
  FOR REC IN C1 LOOP
    BEGIN
      INSERT INTO TBL_ETL_DEPENDENCIES(OWNER,
                                       NAME,
                                       REFERENCED_OWNER,
                                       REFERENCED_NAME,
                                       INSERT_DATE)
      VALUES(REC.OWNER,
             REC.NAME,
             REC.REFERENCED_OWNER,
             REC.REFERENCED_NAME,
             SYSDATE);
    EXCEPTION
      WHEN OTHERS THEN
        -- Handle the exception
        DBMS_OUTPUT.PUT_LINE('Error inserting dependency: ' || SQLERRM);
    END;
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error in SP_INSERT_ETL_DEPENDENCIES: ' || SQLERRM);
END SP_INSERT_ETL_DEPENDENCIES;
/
