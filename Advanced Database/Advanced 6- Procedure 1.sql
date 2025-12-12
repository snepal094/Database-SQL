CREATE TABLE employee_bonus_log(
    employee_id NUMBER PRIMARY KEY,
    fullname VARCHAR2(50), 
    salary NUMBER,
    bonus INT,
    date_updated DATE
);

CREATE TABLE hr_employees AS 
SELECT * FROM HR.EMPLOYEES;

SELECT * FROM hr_employees;

INSERT INTO employee_bonus_log
SELECT employee_id, first_name || ' ' || last_name, salary, 1000, SYSDATE
FROM hr_employees 
WHERE employee_id IN (199, 200, 201, 202, 100);

SELECT * FROM employee_bonus_log;

-- update this table using a procedure that passes two params: employee_id and bonus_percentage

CREATE OR REPLACE PROCEDURE update_bonus (
    p_emp_id IN HR_EMPLOYEES.employee_id%TYPE,
    p_bonus_percentage IN NUMBER
)
IS 
v_name hr_employees.first_name%TYPE;
v_salary hr_employees.salary%TYPE;
v_bonus NUMBER;
BEGIN
    SELECT first_name || ' ' || last_name AS fullname, salary
    INTO v_name, v_salary
    FROM HR_Employees
    WHERE employee_id = p_emp_id;

    v_bonus:= v_salary*p_bonus_percentage/100;

    MERGE INTO employee_bonus_log bon USING (
        SELECT p_emp_id AS emp_id, v_name AS emp_name, v_salary AS emp_salary, v_bonus AS emp_bonus 
        FROM dual) temp
    ON(bon.employee_id=temp.emp_id)
    WHEN MATCHED THEN
    UPDATE SET bon.bonus = temp.emp_bonus, bon.salary = temp.emp_salary+temp.emp_bonus, bon.date_updated= SYSDATE
    WHEN NOT MATCHED THEN 
    INSERT (bon.employee_id, bon.fullname, bon.salary, bon.bonus, bon.date_updated) VALUES
    (temp.emp_id, temp.emp_name, temp.emp_salary+temp.emp_bonus, temp.emp_bonus, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Bonus Log of employee with ID' || ' ' || p_emp_id || ' ' || 'Updated.');

END update_bonus;

EXEC update_bonus(199, 10);
EXEC update_bonus(111,10);

SELECT * FROM employee_bonus_log;
SELECT * FROM hr_employees;

SELECT 1+1 FROM dual;
SELECT * FROM dual;

SELECT * FROM HR.EMPLOYEES;
SHOW ERRORS PROCEDURE update_bonus;

SELECT USER FROM dual;

SELECT table_name 
FROM user_tables;