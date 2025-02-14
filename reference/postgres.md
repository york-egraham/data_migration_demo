# Postgres Reference

## Note - Windows
You may need to add your postgres binaries to path if you freshly installed PgAdmin. Verify this by going to your environmental variables, edit "PATH" variable. There should be a line that shows something similar to this "C:\Program Files\PostgreSQL\17\bin" if you're using version 17.


# Getting Started
## Loading a schema
```bash
# Command Line
psql -h localhost -p 5000 -U postgres -d mydatabase -f .\postgres\schema.sql

# PgAdmin
right-click on mydatabase > select 'Query Tool' > Upload your schema script with Ctrl+o to select the file > execute the script with F5
```

## Seed Sample Data
```bash
# Command Line
psql -h localhost -p 5000 -U postgres -d mydatabase -f .\postgres\seed_data.sql

# PgAdmin
right-click on mydatabase > select 'Query Tool' > Upload your script with Ctrl+o to select the file > execute the script with F5
```

## Backing up the Database
```bash
# Command Line
pg_dump -U postgres -p 5000 mydatabase > ./postgres/backup.sql

# PgAdmin
right-click on mydatabase > select "Backup..." > Create Name > select "Backup" button.
```

## Restoring the Database
```bash
# Command Line
psql -U postgres -p 5000 -d mydatabase -f ./postgres/backup.sql

# PgAdmin
right-click on mydatabase > select "Restore..." > select your backup file.
```

# Sample Queries

### Grab all emails from a specific sender (user 1) and display the content and recipient details. 
`Note` This uses inner joins so only matches between tables are shown.
```sql
SELECT 
    e.id AS email_id,
    e.subject,
    e.body,
    e.sent_date,
    er.recipient_type,
    r.id AS recipient_id,
    r.name AS recipient_name,
    r.email AS recipient_email
FROM emails e
JOIN email_recipients er 
    ON e.id = er.email_id
JOIN users r 
    ON er.user_id = r.id
WHERE e.from_user_id = 1;
```

### Determine the number of average emails sent by each age group
```sql
WITH user_email_counts AS (
    SELECT 
        u.id,
        u.age,
        COUNT(e.id) AS email_count
    FROM users u
    LEFT JOIN emails e 
        ON u.id = e.from_user_id
    GROUP BY u.id, u.age
)
SELECT 
    age,
    COUNT(*) AS user_count,
    SUM(email_count) AS total_emails,
    AVG(email_count) AS avg_emails_per_user
FROM user_email_counts
GROUP BY age
ORDER BY age;
```

# Reference Section
## List of common psql commands
| **Command**      | **Description**                                                              |
|------------------|------------------------------------------------------------------------------|
| `\?`            | Display help for all psql commands.                                          |
| `\q`            | Quit the psql interface.                                                     |
| `\l`            | List all databases.                                                          |
| `\c dbname`     | Connect to a specific database (`dbname`).                                   |
| `\dt`           | List tables in the current database.                                         |
| `\dv`           | List views in the current database.                                          |
| `\di`           | List indexes in the current database.                                        |
| `\d tablename`  | Describe the structure of a table (columns, types, indexes, etc.).           |
| `\df`           | List available functions.                                                    |
| `\dp`           | Show table/view access privileges.                                           |
| `\i filename`   | Execute SQL commands from a file.                                            |
| `\timing`       | Toggle display of execution time for each query.                           |
| `\x`            | Toggle expanded display mode (useful for wide output).                       |




## List of PostgreSQL commands by category

| **Category**           | **Command**                                          | **When to Use**                                                                 |
|------------------------|------------------------------------------------------|---------------------------------------------------------------------------------|
| **Data Definition Language (DDL) - Schema**       | `CREATE TABLE`                                       | To define new tables and database objects.                                    |
|                        | `ALTER TABLE`                                        | To modify an existing table’s structure (e.g., add or remove columns).          |
|                        | `DROP TABLE [IF EXISTS] [CASCADE]`                   | To remove tables (and optionally all dependent objects) from the database.      |
|                        | `CREATE SCHEMA` / `DROP SCHEMA [IF EXISTS] [CASCADE]`  | To organize or remove logical groupings of database objects.                    |
| **Data Manipulation Language (DML) - CRUD**         | `INSERT INTO`                                        | To add new records (rows) into a table.                                         |
|                        | `SELECT`                                             | To retrieve or query data from one or more tables.                              |
|                        | `UPDATE`                                             | To modify existing records in a table.                                          |
|                        | `DELETE`                                             | To remove records from a table.                                                 |
|                        | `INSERT ... ON CONFLICT`                             | To perform an upsert (insert new row or update on conflict).                    |
| **Transaction Control**| `BEGIN; COMMIT; ROLLBACK;`                           | To group operations into an atomic transaction (ensuring all-or-nothing).       |
| **Querying/Aggregation**|  `JOIN` or `INNER JOIN`                             | Returns rows that have matching values in both tables. Use this when you only want records with related data in both tables.                        |
|                        | `LEFT JOIN` or `LEFT OUTER JOIN`           | Returns all rows from the left table and matching rows from the right table (NULLs for non-matches). Use this when you need all records from the left table.  |
|                        | `RIGHT JOIN` or `RIGHT OUTER JOIN`         | Returns all rows from the right table and matching rows from the left table (NULLs for non-matches). Use this when you need all records from the right table.|
|                        | `FULL JOIN` or `FULL OUTER JOIN`           | Returns rows when there is a match in either table, with non-matching rows filled with NULLs. Use this when you want all records from both tables.|
|                        | `CROSS JOIN`                             | Returns the Cartesian product of the two tables (every row from the first combined with every row from the second). Use this sparingly.              |
|                        | `NATURAL JOIN`                           | Automatically joins tables based on all columns with the same names. Use it only when you are certain that the common columns are the correct join keys. |
|                        | `GROUP BY`                                           | To aggregate rows and compute summary statistics (e.g., counts, averages).      |
|                        | `ORDER BY` / `LIMIT`                                 | To sort results and restrict the number of rows returned.                       |
|                        | `WITH (CTE)`                                         | To define temporary result sets (helpful for complex or recursive queries).     |
| **Procedural (PL/pgSQL)** | `CREATE FUNCTION/PROCEDURE`                      | To encapsulate business logic within stored functions or procedures.           |
|                        | Control Structures (`IF`, `LOOP`, `FOREACH`)         | To perform conditional logic and iterations within PL/pgSQL blocks.             |
|                        | `EXCEPTION` handling                                 | To catch and handle errors within PL/pgSQL functions and procedures.            |
