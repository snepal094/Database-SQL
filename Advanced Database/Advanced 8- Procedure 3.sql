CREATE TABLE HR_DEPARTMENTS AS 
SELECT dpt.department_id, dpt.department_name, emp.salary
FROM HR.DEPARTMENTS dpt
JOIN HR.EMPLOYEES emp
ON dpt.department_id=emp.department_id;

SELECT * FROM HR_DEPARTMENTS;

CREATE TABLE dept_info (
    dept_id NUMBER,
    dept_sum NUMBER,
    dept_avg NUMBER,
    dept_count NUMBER,
    calc_date DATE
);

CREATE OR REPLACE PROCEDURE dept_salary_stats(
    p_dept_id IN HR_DEPARTMENTS.department_id%TYPE 
)
IS
v_sum NUMBER;
v_avg NUMBER; 
v_count NUMBER;

e_no_employees_found EXCEPTION;

BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM HR_DEPARTMENTS
    WHERE department_id=p_dept_id;

    IF v_count =0 THEN
    RAISE e_no_employees_found;
    END IF;

    SELECT SUM(salary), ROUND(AVG(salary), 2)
    INTO v_sum, v_avg
    FROM HR_DEPARTMENTS
    WHERE department_id = p_dept_id;

    MERGE INTO dept_info din USING (
        SELECT p_dept_id AS dept_id
        FROM dual
    ) temp
    ON (din.dept_id=temp.dept_id)
    WHEN MATCHED THEN 
    UPDATE SET din.dept_sum= v_sum, din.dept_avg= v_avg, din.dept_count= v_count, din.calc_date= SYSDATE
    WHEN NOT MATCHED THEN
    INSERT (din.dept_id, din.dept_sum, din.dept_avg, din.dept_count, din.calc_date) 
    VALUES (temp.dept_id, v_sum, v_avg, v_count, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Department info updated/inserted.');

    EXCEPTION
        WHEN e_no_employees_found THEN
        DBMS_OUTPUT.PUT_LINE(
            'ERROR: Department ' || p_dept_id || ' has no employees.'
        );
        --department exists, but there are no employees
        
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);

END dept_salary_stats;

EXEC dept_salary_stats(10);
EXEC dept_salary_stats(20);
EXEC dept_salary_stats(30);
EXEC dept_salary_stats(50);

SELECT * FROM dept_info;