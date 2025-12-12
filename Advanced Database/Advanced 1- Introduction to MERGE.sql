-- PROBLEM 1

CREATE TABLE employees(
  emp_id INT PRIMARY KEY,
  name VARCHAR(50),
  salary NUMBER(10,2)
);

CREATE TABLE new_employees(
  emp_id INT PRIMARY KEY,
  name VARCHAR(50),
  salary NUMBER(10,2)
);


SELECT COLUMN_NAME, DATA_TYPE, DATA_PRECISION, DATA_SCALE
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'EMPLOYEES' AND COLUMN_NAME = 'SALARY';

SELECT * FROM USER_TAB_COLUMNS;

INSERT INTO employees VALUES 
(101, 'Alice', 50000),
(102, 'Bob', 55000),
(103, 'Charlie', 60000);

INSERT INTO new_employees VALUES
(102, 'Bob', 58000),
(104, 'Diana', 62000),
(103, 'Charlie', NULL);

SELECT * FROM employees;

SELECT * FROM new_employees;

MERGE INTO employees emp USING new_employees ne
ON (ne.emp_id = emp.emp_id) 
WHEN MATCHED THEN
UPDATE SET emp.salary=ne.salary
DELETE WHERE ne.salary IS NULL
WHEN NOT MATCHED THEN 
INSERT (emp.emp_id, emp.name, emp.salary) VALUES (ne.emp_id, ne.name, ne.salary);

-- emp.field_name is the same as field_name, since any changes done in a merge query is supposed to modify target table itself

--PROBLEM 2

CREATE TABLE new_employees1(
  emp_id INT,
  name VARCHAR(50),
  salary NUMBER(10,2)
);

INSERT INTO new_employees1 VALUES
(102, 'Bob', 58000),
(104, 'Diana', 62000),
(103, 'Charlie', NULL),
(103, 'Chandler', 90000);

SELECT * FROM new_employees1;

CREATE TABLE employees1(
  emp_id INT,
  name VARCHAR(50),
  salary NUMBER(10,2)
);

INSERT INTO employees1 VALUES 
(101, 'Alice', 50000),
(102, 'Bob', 55000),
(103, 'Charlie', 60000);

SELECT * FROM employees1;

MERGE INTO employees1 emp USING new_employees1 ne
ON (ne.emp_id = emp.emp_id) 
WHEN MATCHED THEN
UPDATE SET emp.salary=ne.salary
DELETE WHERE ne.salary IS NULL
WHEN NOT MATCHED THEN 
INSERT (emp.emp_id, emp.name, emp.salary) VALUES (ne.emp_id, ne.name, ne.salary); 

-- ORA-30926: The operation attempted to update the same row (rowid: 'AABh/aAAAAACYh7AAB') twice.
-- MERGE key must be unique: In the source AND in the target
-- both tables do not contain any unique key
-- error occurs