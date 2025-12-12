CREATE TABLE sales_demo (
    sale_id       NUMBER,
    employee_name VARCHAR2(50),
    department    VARCHAR2(30),
    sale_amount   NUMBER,
    sale_date     DATE
);

INSERT INTO sales_demo VALUES (1, 'Alex', 'IT', 500, DATE '2024-01-10'),
                              (2, 'Alex', 'IT', 800, DATE '2024-01-15'),
                              (3, 'Alex', 'IT', 400, DATE '2024-02-02'),

                              (4, 'Bella', 'IT', 700, DATE '2024-01-12'),
                              (5, 'Bella', 'IT', 900, DATE '2024-02-05'),

                              (6, 'Chris',  'HR',      300,  DATE '2024-01-20'),
                              (7, 'Chris',  'HR',      600,  DATE '2024-02-18'),

                              (8, 'Diana',  'HR',      650,  DATE '2024-02-01'),
                              (9, 'Diana',  'HR',     1200,  DATE '2024-02-22'),

                              (10, 'Eva',   'Finance', 400,  DATE '2024-01-28'),
                              (11, 'Eva',   'Finance', 950,  DATE '2024-02-15');


SELECT 
    employee_name,
    sale_amount,
    ROW_NUMBER() OVER (PARTITION BY employee_name ORDER BY sale_amount DESC) AS rn
FROM sales_demo;


SELECT 
    employee_name,
    sale_amount,
    RANK() OVER (PARTITION BY employee_name ORDER BY sale_amount DESC) AS rnk
FROM sales_demo;


SELECT 
    employee_name,
    sale_amount,
    DENSE_RANK() OVER (PARTITION BY employee_name ORDER BY sale_amount DESC) AS drnk
FROM sales_demo;


SELECT
    sale_id,
    employee_name,
    sale_amount,
    LAG(sale_amount) OVER (PARTITION BY employee_name ORDER BY sale_date) AS prev_sale
FROM sales_demo;


SELECT
    sale_id,
    employee_name,
    sale_amount,
    LEAD(sale_amount) OVER (PARTITION BY employee_name ORDER BY sale_date) AS next_sale
FROM sales_demo;


SELECT
    employee_name,
    sale_date,
    sale_amount,
    SUM(sale_amount) OVER (
        PARTITION BY employee_name 
        ORDER BY sale_date
    ) AS running_total
FROM sales_demo;


SELECT
    sale_id,
    sale_amount,
    SUM(sale_amount) OVER (ORDER BY sale_date) AS company_running_total
FROM sales_demo;


SELECT
    employee_name,
    sale_date,
    sale_amount,
    AVG(sale_amount) OVER (
        PARTITION BY employee_name
        ORDER BY sale_date
    ) AS moving_avg
FROM sales_demo;


SELECT
    employee_name,
    sale_amount,
    PERCENT_RANK() OVER (PARTITION BY employee_name ORDER BY sale_amount) AS pct_rank
FROM sales_demo;