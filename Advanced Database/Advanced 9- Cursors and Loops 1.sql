DECLARE 
v_emp_name employees00.firstname%TYPE; 
v_salary employees00.salary%TYPE;
BEGIN
    SELECT firstname, salary INTO v_emp_name, v_salary
    FROM employees00 
    WHERE employee_id=52;

    DBMS_OUTPUT.PUT_LINE('Employee: '||v_emp_name|| ' has the salary of: ' ||v_salary);
    DBMS_OUTPUT.PUT_LINE('Rows processed: '|| SQL%ROWCOUNT); --SQL because rowcount is an attribute of the cursor, and this cursor is implicit
END; -- anonymous PL/SQL block (not stored in the database) using an implicit cursor

SELECT * FROM employees00;

-- anonymous PL/SQL block using an explicit cursor
DECLARE 
CURSOR emp_cur IS SELECT firstname, salary FROM employees00;
v_emp_name employees00.firstname%TYPE; 
v_salary employees00.salary%TYPE;
BEGIN
    OPEN emp_cur;
    LOOP
        FETCH emp_cur INTO v_emp_name, v_salary; -- so that the rows are processed one by one
        EXIT WHEN emp_cur%NOTFOUND; -- when the rows end
        DBMS_OUTPUT.PUT_LINE('Employee '||v_emp_name|| ' has the salary of: ' ||v_salary);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Rows processed: '|| emp_cur%ROWCOUNT); -- cursor is explicit, hence the name of the cursor
    CLOSE emp_cur;
END;

BEGIN
    FOR i IN (SELECT firstname, salary FROM employees00) LOOP
    DBMS_OUTPUT.PUT_LINE('Employee '|| i.firstname || ' has the salary of: ' || i.salary);
    END LOOP;
END;

SELECT * FROM employees00;

SELECT * FROM hr_employees;

-- update the salary of those with salary <5000 by 10%
DECLARE v_sal NUMBER;
BEGIN
    FOR i IN (SELECT firstname, salary FROM employees00 WHERE salary < 5000) LOOP
    DBMS_OUTPUT.PUT_LINE('Salary of '|| i.firstname || ' updated from: ' || i.salary);
    v_sal:= i.salary + (1/10) * i.salary;
    UPDATE employees00 SET salary = v_sal WHERE firstname=i.firstname;
    DBMS_OUTPUT.PUT_LINE('To: '||v_sal);
    END LOOP;
END;

-- type conversion (to_char()) in dbms_output
DECLARE v_sal NUMBER;
BEGIN
    FOR i IN (SELECT first_name, salary FROM hr_employees WHERE salary < 5000) LOOP
    DBMS_OUTPUT.PUT_LINE('Salary of '|| i.first_name || ' updated from: ' || i.salary || ' to ' || to_char(i.salary + (1/10) * i.salary));
    UPDATE hr_employees SET salary = i.salary + (1/10) * i.salary WHERE first_name=i.first_name;
    END LOOP;
END;

select * from employees00;

SELECT * FROM HR_EMPLOYEES;

SELECT * FROM HR.EMPLOYEES;