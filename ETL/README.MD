SP_LOAD_EMPLOYEE_DATA Procedure
Purpose

This procedure loads updated employee data from the HR schema into a corresponding table in the DATA_WAREHOUSE schema. It ensures that the data warehouse reflects the latest employee information.
Functionality

    Data Collection: Fetches employee details from HR.EMPLOYEES based on the last update date.
    Data Synchronization: Uses a merge operation to update existing records and insert new records into DATA_WAREHOUSE.EMPLOYEE_DATA.
    Transaction Management: Commits changes if no exceptions occur to maintain data integrity.
    Exception Handling: Logs errors using DBMS_OUTPUT for debugging purposes.

Usage

Execute the procedure as follows:

sql

BEGIN
    SP_LOAD_EMPLOYEE_DATA;
END;
/

Prerequisites

    Execute with appropriate privileges for HR.EMPLOYEES and DATA_WAREHOUSE.EMPLOYEE_DATA.
    Ensure tables and necessary objects exist as described.

Error Handling

Basic error handling logs and displays errors encountered during execution.
Repository Organization

Ensure the procedure script is stored in a dedicated directory within your repository:

root/
│
└── sql_scripts/
    └── SP_LOAD_EMPLOYEE_DATA.sql

README.md (Repository-wide)

Provide an overview including the SP_LOAD_EMPLOYEE_DATA procedure:

markdown

# Repository Name

This repository contains scripts for data management tasks.

## SP_LOAD_EMPLOYEE_DATA Procedure

Synchronizes employee data from HR to a data warehouse, ensuring the latest updates are reflected.

### Usage

```sql
BEGIN
    SP_LOAD_EMPLOYEE_DATA;
END;
/

Prerequisites

    Proper execution privileges required.
    Ensure tables HR.EMPLOYEES and DATA_WAREHOUSE.EMPLOYEE_DATA exist.

Error Handling

Basic error handling logs errors using DBMS_OUTPUT