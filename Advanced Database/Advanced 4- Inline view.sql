-- Inline view
SELECT e.first_name || ' ' || e.last_name as name, e.salary, d.avg_salary, hd.department_name
from hr.employees e
join
(
    select department_id, ROUND(AVG(salary),2) as avg_salary
    from hr.employees
    group by department_id
) d
on  e.department_id = d.Department_id
JOIN hr.departments hd
on d.department_id = hd.department_id;

--An inline view in SQL is essentially a subquery used in the FROM clause of a main query. 
--It acts like a temporary table that exists only for the duration of the query execution.