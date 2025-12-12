CREATE TABLE employees(
    emp_id NUMBER PRIMARY KEY,
    name VARCHAR(20),
    salary NUMBER
);

CREATE OR REPLACE PROCEDURE add_emp(
    p_id IN NUMBER,
    p_name IN VARCHAR2,
    p_salary IN NUMBER
)
IS
BEGIN
    INSERT INTO employees(emp_id, name, salary)
    VALUES (p_id, p_name, p_salary);

    DBMS_OUTPUT.PUT_LINE('Employee added succesfully');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Employee ID already exists.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occured.'||SQLERRM);
END add_emp;
/

EXEC add_emp(102, 'Santosh', 2000); -- Error: Employee ID already exists.

--SELECT * FROM Employees;

INSERT INTO employees VALUES (1, 'Ram', 50000);

SELECT * FROM Employees;

CREATE OR REPLACE PROCEDURE del_employees
IS
BEGIN
    DELETE FROM Employees; -- deletes all data
    DBMS_OUTPUT.PUT_LINE('Data deleted successfully.');
END del_employees;

EXEC del_employees; 

SELECT * FROM employees;