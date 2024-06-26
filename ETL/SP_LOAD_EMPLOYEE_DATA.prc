CREATE OR REPLACE PROCEDURE SP_LOAD_EMPLOYEE_DATA IS
    TYPE EMPLOYEE_DATA_TABTYPE IS TABLE OF HR.EMPLOYEES%ROWTYPE INDEX BY PLS_INTEGER;
    L_EMP_DATA EMPLOYEE_DATA_TABTYPE;
BEGIN
    -- FETCHING EMPLOYEE DATA INTO COLLECTION
    SELECT E.EMPLOYEE_ID,
           E.FIRST_NAME,
           E.LAST_NAME,
           E.EMAIL,
           E.PHONE_NUMBER,
           E.HIRE_DATE,
           E.JOB_ID,
           E.SALARY,
           E.COMMISSION_PCT,
           E.MANAGER_ID,
           E.DEPARTMENT_ID,
           E.LAST_UPDATE_DATE
    BULK COLLECT INTO L_EMP_DATA
    FROM HR.EMPLOYEES E
    WHERE LAST_UPDATE_DATE > SYSDATE - 1;

    -- PROCESSING EACH RECORD IN THE COLLECTION
    FORALL I IN 1 .. L_EMP_DATA.COUNT
        MERGE INTO DATA_WAREHOUSE.EMPLOYEE_DATA DW
        USING DUAL
        ON (DW.EMPLOYEE_ID = L_EMP_DATA(I).EMPLOYEE_ID)
        WHEN MATCHED THEN
            UPDATE SET
                DW.FIRST_NAME = L_EMP_DATA(I).FIRST_NAME,
                DW.LAST_NAME = L_EMP_DATA(I).LAST_NAME,
                DW.EMAIL = L_EMP_DATA(I).EMAIL,
                DW.DEPARTMENT_ID = L_EMP_DATA(I).DEPARTMENT_ID
        WHEN NOT MATCHED THEN
            INSERT (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, DEPARTMENT_ID)
            VALUES (L_EMP_DATA(I).EMPLOYEE_ID, L_EMP_DATA(I).FIRST_NAME, L_EMP_DATA(I).LAST_NAME,
                    L_EMP_DATA(I).EMAIL, L_EMP_DATA(I).DEPARTMENT_ID);

    -- HANDLING EXCEPTIONS
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/
