SELECT department_id,
LISTAGG(
    first_name || ' ' || last_name, ', '
)
WITHIN GROUP (ORDER BY last_name ASC) AS emp_names
FROM hr.employees
GROUP BY department_id;

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
