SELECT * FROM employees00;

SELECT department_id,
LISTAGG(
    firstname || ' ' || lastname, ', '
)
WITHIN GROUP (ORDER BY lastname ASC) AS emp_names
FROM employees00
GROUP BY department_id;

ALTER TABLE employees00 DROP COLUMN department_name;

CREATE TABLE departments (
    department_id INT,
    department_name VARCHAR2(50)
);

INSERT INTO departments VALUES
(10, 'HR'),
(20, 'IT'),
(30, 'Finance'),
(40, 'Marketing'),
(50, 'Admin');

SELECT * FROM employees00;
SELECT * FROM departments;

SELECT emp.department_id, dept.department_name,
LISTAGG(
    emp.first_name || ' ' || emp.last_name, ', '
)
WITHIN GROUP (ORDER BY HIRE_DATE ASC) AS emp_names
FROM hr.employees emp
JOIN hr.departments dept
ON emp.department_id=dept.department_id
GROUP BY emp.department_id, dept.department_name;

--do the same thing but using job_id instead of name and check for distinct

SELECT department_id,
       LISTAGG(DISTINCT(job_id), ', ') 
       WITHIN GROUP(ORDER BY first_name) AS job_ids
FROM HR.employees
GROUP BY department_id;
