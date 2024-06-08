Overview

This README provides detailed information about the purpose, functionality, and usage of three Oracle PL/SQL stored procedures designed for managing dependencies, constraints, and table structures in a data warehouse environment. These procedures include:

    SP_INSERT_ETL_DEPENDENCIES
    SP_REMOVE_TABLE_CONSTRAINTS
    SP_SYNC_STG_TABLE_STRUCTURE

Procedures
1. SP_INSERT_ETL_DEPENDENCIES

Purpose:
This procedure manages and records the dependencies of a specified ETL procedure. It identifies all table dependencies of the given procedure and updates a dedicated table (TBL_ETL_DEPENDENCIES) to reflect these dependencies.

Functionality:

    Deletes any existing dependencies for the specified ETL procedure from TBL_ETL_DEPENDENCIES.
    Inserts new dependencies based on the current state of the specified procedure.
    Includes error handling to ensure any issues during the process are logged and the transaction is rolled back if necessary.

Usage:
This procedure is typically used when there are changes to an ETL procedure to ensure all dependencies are accurately recorded. This helps maintain data integrity and consistency across the data warehouse.


2. SP_REMOVE_TABLE_CONSTRAINTS

Purpose:
This procedure is designed to remove all constraints from a specified table. Constraints include primary keys, foreign keys, unique constraints, and others that may affect data modification operations.

Functionality:

    Iterates through all constraints of the specified table and removes them.
    Each constraint removal is handled individually, with error handling to ensure that if an error occurs during the removal of a specific constraint, it is logged, but the process continues for other constraints.

Usage:
This procedure is useful during operations that require schema modifications, data migrations, or other maintenance tasks where constraints need to be temporarily removed.


3. SP_SYNC_STG_TABLE_STRUCTURE

Purpose:
This procedure ensures that the structure of a staging table matches the structure of the corresponding core table. It checks for differences in column definitions and updates the staging table to align with the core table.

Functionality:

    Compares the structure of the core table with the staging table, identifying any columns that need to be added or modified.
    Alters the staging table to add new columns or modify existing columns as needed.
    Logs all changes to a table (TBL_STG_STRUCTURE_CHANGE_LOG) for auditing purposes.
    Includes comprehensive error handling to manage any issues during the comparison and alteration processes.

Usage:
This procedure is particularly useful in environments where the schema of core tables may change, and the staging tables need to be kept in sync to ensure proper data loading and processing.
General Notes on Exception Handling

Each procedure includes robust exception handling mechanisms:

    Specific error messages are logged using DBMS_OUTPUT.PUT_LINE for ease of debugging.
    Transactions are rolled back in case of errors to prevent partial updates, ensuring data consistency and integrity.
    Each significant operation within the procedures has its own exception handling block to capture and report specific errors, aiding in precise troubleshooting.

Prerequisites

    Ensure that the user executing these procedures has the necessary privileges to perform operations on the relevant tables and constraints.
    The logging tables (TBL_ETL_DEPENDENCIES and TBL_STG_STRUCTURE_CHANGE_LOG) should be created and accessible.

Conclusion

These procedures are essential tools for managing ETL dependencies, table constraints, and synchronizing table structures in a data warehouse environment. Proper usage and understanding of these procedures will greatly enhance the efficiency and reliability of database management tasks.
