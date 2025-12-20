CREATE GLOBAL TEMPORARY TABLE temp_employees(
    emp_id NUMBER,
    name VARCHAR2(50),
    salary NUMBER
) ON COMMIT DELETE ROWS; 

-- GLOBAL TEMPORARY TABLE
-- structure is permanent
-- data is temporary

-- there are other types of temporary tables
-- PRIVATE TEMPORARY TABLES (Oracle): Both table structure and data exist only for the current session. Table is dropped when session ends.

INSERT INTO TEMP_EMPLOYEES VALUES (1, 'Ram', 99999);

SELECT * FROM TEMP_EMPLOYEES; 
-- No items to display.

-- ON COMMIT DELETE ROWS
-- Any inserted rows are deleted automatically when a transaction commits.
-- In SQL tools like FreeSQL or Oracle SQL Developer:
-- Each statement is often run in its own transaction, which is committed automatically after the statement executes.
-- So the INSERT was auto-committed, deleting the row immediately because of ON COMMIT DELETE ROWS.
-- That’s why SELECT finds nothing.

CREATE GLOBAL TEMPORARY TABLE temp_employees1(
    emp_id NUMBER,
    name VARCHAR2(50),
    salary NUMBER
) ON COMMIT PRESERVE ROWS;

INSERT INTO TEMP_EMPLOYEES1 VALUES (1, 'Ramesh', 10000);

SELECT * FROM TEMP_EMPLOYEES1;

-- ON COMMIT PRESERVE ROWS
-- the row will stay for the session, even after commit.
-- Data will disappear only when the session ends.

-- both delete and preserve show no items here but in oracleDB, preserve and delete work as intended

-- Task: Use CTE from hr.employees and display first_name, salary, average salary and department 

WITH dept_sal AS(
    SELECT department_id, ROUND(AVG(salary), 2) AS avg_sal
    FROM HR.EMPLOYEES
    GROUP BY department_id
)
SELECT emp.first_name, emp.salary, emp.department_id, d.department_name, dept.avg_sal
FROM hr.employees emp
INNER JOIN dept_sal dept
ON emp.department_id=dept.department_id
INNER JOIN hr.departments d 
ON dept.department_id=d.department_id;

-- same problem, without cte (using correlated query)
SELECT 
    e.first_name,
    e.salary,
    e.department_id,
    d.department_name,
    (SELECT ROUND(AVG(salary), 2)
     FROM hr.employees
     WHERE department_id = e.department_id) AS avg_sal
FROM hr.employees e
JOIN hr.departments d
ON e.department_id = d.department_id;
