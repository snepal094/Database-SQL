INSERT INTO hr_emps
SELECT * FROM HR.EMPLOYEES;

SELECT * FROM hr_emps;

-- Problem: 
-- Salary < 5000 → 10% increment 
-- Salary between 5000–10000 → 5% increment
-- Others → no change 

DECLARE
v_sal NUMBER;
BEGIN
    FOR i IN (SELECT first_name, salary, employee_id FROM hr_emps) LOOP
    DBMS_OUTPUT.PUT_LINE('Salary of '|| i.first_name || ' updated from: ' || i.salary);
    v_sal := CASE 
                WHEN i.salary < 5000 THEN i.salary + (1/10) * i.salary
                WHEN i.salary BETWEEN 5000 AND 10000 THEN i.salary +(1/20) * i.salary
                ELSE i.salary
            END;
    UPDATE hr_emps SET salary = v_sal WHERE employee_id=i.employee_id;
    DBMS_OUTPUT.PUT_LINE('To :' || v_sal);

    END LOOP;
END;
/

-- Task: Pass a department_id to the cursor and display the data of employees of that department

CREATE OR REPLACE PROCEDURE department_info(p_dept_id NUMBER) IS
CURSOR EMP_CUR(DEPT_ID NUMBER) IS
    SELECT FIRST_NAME, SALARY FROM hr_emps WHERE DEPARTMENT_ID=DEPT_ID;
V_EMP_NAME hr_emps.FIRST_NAME%TYPE;
V_SALARY hr_emps.SALARY%TYPE;
BEGIN
    OPEN EMP_CUR(p_dept_id);

    LOOP
        FETCH EMP_CUR INTO V_EMP_NAME, V_SALARY;
        EXIT WHEN EMP_CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('EMPLOYEE: '|| V_EMP_NAME || ', ' || 'SALARY: '|| V_SALARY);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('ROWS PROCESSED: '|| EMP_CUR%ROWCOUNT);

    CLOSE EMP_CUR;
END;

EXEC department_info(30);