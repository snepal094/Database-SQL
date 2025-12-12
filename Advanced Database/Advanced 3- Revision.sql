SELECT * FROM hr.employees;

--CASE WHEN revision

SELECT salary, 
CASE WHEN salary < 5000 THEN 'Low salary'
     WHEN salary > 10000 THEN 'High salary'
     ELSE 'Medium Salary' 
END AS sal_group
FROM HR.employees;

--Procedure Revision
CREATE OR REPLACE PROCEDURE add_nums(
    num1 IN NUMBER,
    num2 IN NUMBER
)
IS
add_result NUMBER;
BEGIN 
    add_result:= num1+num2;
    DBMS_OUTPUT.PUT_LINE('sum: '||add_result);
END add_nums;    

EXEC add_nums(2,4);

CREATE TABLE employees99(
    emp_id NUMBER PRIMARY KEY,
    name VARCHAR2(50),
    salary NUMBER,
    status VARCHAR2(10)
);

CREATE TABLE stg_employees(
    emp_id NUMBER,
    name VARCHAR2(50),
    salary NUMBER,
    status VARCHAR2(10)
);


INSERT INTO employees99
SELECT employee_id, first_name || ' ' || last_name, salary, 
CASE WHEN salary>=10000 THEN 'High'
     WHEN salary<10000 THEN 'Low'
     END AS status
FROM hr.employees;

SELECT * FROM employees99;

UPDATE employees99 
SET salary=10000, status='High' WHERE status='Low';