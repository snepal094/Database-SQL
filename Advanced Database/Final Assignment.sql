CREATE TABLE hr_employees AS
SELECT * FROM HR.EMPLOYEES;

-- Question 1
-- List the names of employees who earn more than the average salary of their department. 
-- use subquery + join

SELECT emp.first_name || ' ' || emp.last_name AS emp_name, 
       emp.department_id, 
       emp.salary, 
       avr.avg_sal_dept
FROM hr_employees emp
INNER JOIN (
    SELECT department_id, ROUND(AVG(salary),2) AS avg_sal_dept
    FROM HR_EMPLOYEES
    GROUP BY department_id
) avr
ON emp.department_id = avr.department_id
WHERE emp.salary>avr.avg_sal_dept;



-- Question 2
-- Find employees who earn the highest salary in their department. 
-- use correlated subquery + groupby

SELECT first_name || ' ' || last_name AS emp_name, 
       salary, 
       hre1.department_id, 
       hrd.department_name
FROM HR_EMPLOYEES hre1
INNER JOIN HR.DEPARTMENTS hrd
ON hre1.department_id=hrd.department_id 
WHERE salary = (
    SELECT MAX(salary)
    FROM HR.EMPLOYEES hre2
    WHERE hre2.department_id = hre1.department_id
);



-- Question 3
-- Find the number of subordinates each manager has.
-- use self join + aggregation

SELECT hre1.manager_id, COUNT(*) AS num_sub
FROM HR_EMPLOYEES hre1
JOIN HR_EMPLOYEES hre2
ON hre1.manager_id=hre2.employee_id
GROUP BY hre1.manager_id;

SELECT manager_id, COUNT(*) FROM HR.EMPLOYEES GROUP BY manager_id; -- takes null into account

-- Question 4
-- You are given a table employee_updates with updated salary and job_id for some employees.
-- Create a MERGE statement to update the employees table accordingly. 
-- Also, insert a record into employee_log table for each update with 
-- employee_id, old_salary, new_salary, update_date. 

SELECT * FROM HR_EMPLOYEES;

CREATE TABLE employee_updates (
    employee_id NUMBER,
    updated_salary NUMBER,
    job_id VARCHAR2(50)
);

INSERT INTO employee_updates VALUES
(199, 5200, 'AD_ASST'),
(200, 8800, 'MK_MAN'),
(201, 26000, 'MK_REP');

SELECT * FROM employee_updates;

CREATE TABLE employee_logs (
    employee_id INT,
    old_salary NUMBER,
    new_salary NUMBER,
    update_date DATE
);

SELECT * FROM employee_logs;

INSERT INTO employee_logs(employee_id, old_salary, new_salary, update_date)
SELECT emp.employee_id, emp.salary, up.updated_salary, SYSDATE
FROM hr_employees emp
INNER JOIN employee_updates up
ON emp.employee_id = up.employee_id;

MERGE INTO hr_employees hre 
USING employee_updates up 
ON (hre.employee_id=up.employee_id)
WHEN MATCHED THEN 
UPDATE SET hre.salary=up.updated_salary, hre.job_id=up.job_id;

SELECT * FROM hr_employees;


-- Question 5
-- Find duplicate records and delete them
-- Find all duplicate records based on first_name, last_name, hire_date and email
-- (Insert some duplicate records in case there aren't any.)
-- Show the duplicate group with a count of how many time each appears.
-- Include the employee_id value for each duplicate.
-- Ensure your deletion logic is safe and does not remove all records from a group.

SELECT column_name, data_type, data_length
FROM user_tab_columns
WHERE table_name = 'HR_EMPLOYEES';

SELECT * FROM hr_employees WHERE hire_date= DATE '2018-01-13';

-- job_id is not nullable, hence the insert
INSERT INTO HR_EMPLOYEES (employee_id, first_name, last_name, email, hire_date, job_id) VALUES
(199, 'Douglas', 'Grant', 'DGRANT', DATE '2018-01-13', 'SH_CLERK'),
(199, 'Douglas', 'Grant', 'DGRANT', DATE '2018-01-13', 'SH_CLERK'),
(199, 'Douglas', 'Grant', 'DGRANT', DATE '2018-01-13', 'SH_CLERK'),
(200, 'Jennifer', 'Whalen', 'JWHALEN', DATE '2013-09-17', 'AD_ASST'),
(201, 'Michael', 'Martinez', 'MMARTINE', DATE '2014-02-17', 'MK_MAN'),
(202, 'Pat', 'Davis', 'PDAVIS', DATE '2015-08-17', 'MK_REP');

SELECT * 
FROM hr_employees 
WHERE rowid NOT IN (
    SELECT MIN(ROWID)
    FROM hr_employees
    GROUP BY first_name, last_name, email, hire_date
) 
-- gives redundant rows (not the original row)
-- the lowest rowid keeps the orignal row
-- rowid is a pseudo column that stores physical address
-- rowid contains data object id (table), file number, block number, and row number within the block
-- oracle inserts new blocks into new rows (new row positions)
-- so the row that was inserted first gets assigned the lowest physical address, i.e. the lowest rowid value 

DELETE FROM hr_employees WHERE rowid NOT IN (
    SELECT MIN(ROWID)
    FROM hr_employees
    GROUP BY first_name, last_name, email, hire_date, job_id
)

-- other methods such as methods using window functions can be used, but only using a unique identifier like rowid or a primary key

-- hypothetically, if there was a field called 'id' which was unique, the duplicates could be removed in the following way
-- assumption: no two dupliacates share the same id (used rowid here)

-- DELETE FROM hr_employees
-- WHERE id IN (
--     SELECT id FROM (
--         SELECT id,
--                ROW_NUMBER() OVER (
--                    PARTITION BY employee_id, first_name, last_name, email, hire_date, job_id
--                    ORDER BY id
--                ) AS rn
--         FROM hr_employees
--     )
--     WHERE rn > 1
-- );


-- ADVANCED

-- CTE BASED
-- Question 6
-- You are tasked with identifying top-performing employees from departments that not only have above-average salaries but also more than 5 employees. 
-- Use two CTEs to structure your logic and join them to get the final result. 
-- Use HR.EMPLOYEES and HR.DEPARTMENTS

WITH dept_stats AS (
    SELECT department_id, COUNT(*) AS num_employees, ROUND(AVG(salary),2) AS avg_per_dept
    FROM hr_employees
    GROUP BY department_id
    HAVING num_employees >= 5
),
top_earners AS (
    SELECT first_name || ' ' || last_name AS emp_name,
           employee_id,
           salary, 
           department_id
    FROM hr_employees hre
    WHERE salary > (
        SELECT avg_per_dept FROM dept_stats ds WHERE hre.department_id = ds.department_id
    )
)
SELECT hrd.department_name, te.employee_id, te.emp_name, te.salary, dpts.avg_per_dept, dpts.num_employees
FROM top_earners te 
JOIN dept_stats dpts
ON te.department_id = dpts.department_id
JOIN HR.DEPARTMENTS hrd
ON dpts.department_id = hrd.department_id;

-- PL/SQL

-- Question 7
-- Create a PL/SQL procedure named update_bonus that updates employee bonus information based on the hr_employees table. 
-- ( emp_bonus_log with columns emp_id, emp_name, salary, bonus, updated_date.) 
-- Use a MERGE statement to: 
-- Update emp_bonus_log if the employee already exists. 
-- Insert a new record if not. 
-- display meaningful messages using DBMS_OUTPUT 
-- and handle no_data_found exception if the employee ID doesn’t exist.  

SELECT * FROM HR_EMPLOYEES;

CREATE TABLE employee_bonus_log(
    employee_id NUMBER PRIMARY KEY,
    fullname VARCHAR2(50), 
    salary NUMBER,
    bonus INT,
    date_updated DATE
);

INSERT INTO employee_bonus_log
SELECT employee_id, first_name || ' ' || last_name, salary, 1000, SYSDATE
FROM hr_employees 
WHERE employee_id IN (199, 200, 201, 202, 100);

SELECT * FROM employee_bonus_log;

CREATE OR REPLACE PROCEDURE update_bonus (
    p_emp_id IN HR_EMPLOYEES.employee_id%TYPE,
    p_bonus_percentage IN NUMBER
)
IS 
v_name employee_bonus_log.fullname%TYPE;
v_salary employee_bonus_log.salary%TYPE;
v_bonus employee_bonus_log.bonus%TYPE;
v_count NUMBER;
no_employee_data_found EXCEPTION;
BEGIN
     
    SELECT COUNT(*)
    INTO v_count
    FROM HR_EMPLOYEES 
    WHERE employee_id = p_emp_id;

    IF v_count=0 THEN 
    RAISE no_employee_data_found;
    END IF;


    SELECT first_name || ' ' || last_name, salary
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

    EXCEPTION 
    WHEN no_employee_data_found THEN
    DBMS_OUTPUT.PUT_LINE('Employee with employee id' || ' ' || p_emp_id || ' does not exist.');

    WHEN others THEN
    DBMS_OUTPUT.PUT_LINE('Unexpected error. ' || SQLERRM);

END update_bonus;

EXEC update_bonus (199, 10); -- updated
EXEC update_bonus(201, 10); -- updated
EXEC update_bonus(145, 50); -- inserted
EXEC update_bonus(555, 10); -- exception

SELECT * FROM employee_bonus_log;

-- Question 8
-- Write a stored procedure that uses a cursor to iterate through all employees and increases their salary by 10% if they have been hired before 2010.
-- (do before 2013 (2012 and 2011) since there is no data of 2010 in hr_employees)  
-- Use a cursor on hire_date. 
-- Use UPDATE inside the loop.

SELECT * FROM hr_employees WHERE EXTRACT(YEAR FROM hire_date) < 2013;
-- 8 rows (7 from 2012 and 1 from 2011)

-- an anonymous PL/SQL block would do the same thing (one with DECLARE instead of CREATE...PROCEDURE), 
-- but writing this logic inside a procedure enables you to reuse this block

CREATE OR REPLACE PROCEDURE sal_incr 
IS
CURSOR emp_cur IS 
SELECT employee_id FROM hr_employees WHERE EXTRACT(YEAR FROM hire_date) < 2013;
v_id hr_employees.employee_id%TYPE;
BEGIN
    OPEN emp_cur;
    LOOP
        FETCH emp_cur INTO v_id;
        EXIT WHEN emp_cur%NOTFOUND;
        -- DBMS_OUTPUT.PUT_LINE(v_id || ' ' || v_date);
        UPDATE hr_employees SET salary= salary+ (salary/10) WHERE employee_id=v_id;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Rows processed: ' || emp_cur%ROWCOUNT);
    CLOSE emp_cur;
    -- END;
END sal_incr;

SELECT * FROM hr_employees WHERE EXTRACT(YEAR FROM hire_date) < 2013;

EXEC sal_incr;

-- Question 9
-- Create a procedure that loops through all departments 
-- and prints the department name and the number of employees in each. 
-- If the count is zero, print “No employees”.(Cursor with Conditional Logic) 
-- Use a cursor on departments. 
-- Use conditional logic inside the loop.

CREATE TABLE hr_departments AS
SELECT * FROM hr.departments;

INSERT INTO hr_departments (department_id, department_name, manager_id, location_id) VALUES
(999, 'HR', NULL, NULL);

SELECT * FROM hr_departments;

CREATE PROCEDURE dept_count
IS
CURSOR dept_cur IS
SELECT hre.department_id, hrd.department_name, COUNT(hre.employee_id)
FROM hr_departments hrd
LEFT JOIN hr_employees hre  
ON hrd.department_id=hre.department_id
GROUP BY hre.department_id, hrd.department_name;
v_d_id hr_departments.department_id%TYPE;
v_d_name hr_departments.department_name%TYPE;
v_count NUMBER;
BEGIN
    OPEN dept_cur;
    LOOP 
        FETCH dept_cur INTO v_d_id, v_d_name, v_count;        
        EXIT WHEN dept_cur%NOTFOUND;
        IF v_count=0 THEN 
                DBMS_OUTPUT.PUT_LINE('Department '|| v_d_name || ' has no employees.');
        ELSE 
        DBMS_OUTPUT.PUT_LINE('Department ' ||v_d_name || ' has ' || v_count || ' employees.');
        END IF;
    END LOOP;
    CLOSE dept_cur;

END dept_count; 

EXEC dept_count;

-- Question 10
-- Create a procedure that prints each manager’s name followed by the names of their direct reports.
-- (Nested Cursor) 
-- Use an outer cursor for managers. 
-- Use an inner cursor for employees reporting to each manager. 


CREATE OR REPLACE PROCEDURE manager_info IS 

CURSOR outer_cur IS
SELECT DISTINCT(employee_id) AS man_id, first_name || ' ' || last_name AS manager_name
FROM hr_employees hr1
WHERE employee_id IN (
    SELECT manager_id FROM hr_employees
)
ORDER BY man_id;-- doesn't include null manager_id

CURSOR inner_cur (p_m_id NUMBER) IS
SELECT first_name || ' ' || last_name AS emp_name
FROM hr_employees
WHERE manager_id = p_m_id;

v_m_id NUMBER;
v_m_name VARCHAR2(50);
v_e_name VARCHAR(300);

BEGIN
    OPEN outer_cur;
    LOOP
        FETCH outer_cur INTO v_m_id, v_m_name;
        EXIT WHEN outer_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Manager ' || v_m_name || '(' || v_m_id || ')' || 'has the following people under him: ');
        OPEN inner_cur(v_m_id);
        LOOP
            FETCH inner_cur INTO v_e_name;
            EXIT WHEN inner_cur%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_e_name || ' ');
            -- DBMS_OUTPUT.PUT_LINE('');
        END LOOP;
        CLOSE inner_cur;
    END LOOP;
    CLOSE outer_cur;

END manager_info;
/

select * from hr_employees;


EXEC manager_info;
