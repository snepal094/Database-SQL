CREATE DATABASE PROJECT;

USE PROJECT;

CREATE TABLE stg_customers (
  customer_id INT,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phonenumber VARCHAR(255),
  city VARCHAR(100),
  updated_at DATETIME2,
  loaded_file_name VARCHAR(255),
  LoadedDateTime DATETIME2 
);

CREATE TABLE stg_products (
  product_id INT ,
  name VARCHAR(255),
  category VARCHAR(100),
  price INT,	
  updated_at DATETIME2,
  load_file_name VARCHAR(255),
  LoadedDateTime DATETIME2 
);
 
CREATE TABLE stg_sales (
  sale_id BIGINT,
  product_id INT,
  customer_id INT,
  qty INT,
  Price INT,
  total_amt BIGINT,
  sale_date DATE,
  load_file_name VARCHAR(255),
  LoadedDateTime DATETIME2 
);


-- If a customer buys multiple different products in the same transaction (same day), 
-- there will be multiple rows with the same sale_id but different product_ids.

-- Each row is independent in the sense that it represents one product (quantity can be more than 1) in the purchase, 
-- but they are related through the sale_id.




CREATE TABLE fact_sales ( -- incremental load (from stg_sales) 
  product_sk INT IDENTITY(1,1) PRIMARY KEY,
  sale_id BIGINT ,
  product_id INT,
  customer_id INT,
  qty INT,
  Price INT,
  Total_amt BIGINT,
  sale_date DATE,
  LoadedDateTime DATETIME2
); -- dim_sales

-- stg_sales → contains TODAY’S transactions (temporary)
-- fact_sales → contains ALL transactions across ALL days (historical)
-- Incremental load → only new stg_sales rows are inserted into fact_sales



CREATE TABLE dim_customers (
  customer_sk INT IDENTITY(1,1) PRIMARY KEY,
  customer_id INT ,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phonenumber VARCHAR(255),
  city VARCHAR(100),
  is_active BIT,
  start_date DATETIME,
  end_date DATETIME NULL,
  LastUpdatedDateTime DATETIME2 -- last time a real attribute change occurred
);
 
CREATE TABLE dim_products (
  product_sk INT IDENTITY(1,1) PRIMARY KEY,
  product_id INT ,
  name VARCHAR(255),
  category VARCHAR(100),
  price INT,	
  total_qty_sold BIGINT,
  is_active BIT,
  start_date DATETIME,
  end_date DATETIME NULL,
  LastUpdatedDateTime DATETIME2
);



CREATE TABLE inventory_daily (
product_id INT,
inventory_date DATE,
BOH INT,
EOH INT
);



CREATE TABLE etl_audit (
  audit_id INT IDENTITY(1,1) PRIMARY KEY,
  package_name VARCHAR(200),
  run_start DATETIME,
  run_end DATETIME,
  status VARCHAR(50),
  error_message VARCHAR(MAX)
);



SELECT * FROM stg_sales;
SELECT * FROM stg_products;
SELECT * FROM stg_customers;


SELECT * FROM dim_customers;
SELECT * FROM dim_products;


SELECT * FROM fact_sales;

SELECT * FROM etl_audit;

SELECT * FROM inventory_daily;




INSERT INTO etl_audit VALUES ('Package', '2025-12-07', '2025-12-07', 'Success', NULL);

UPDATE etl_audit SET run_end = '2025-12-08' WHERE audit_id=2;




TRUNCATE TABLE stg_sales;
TRUNCATE TABLE stg_customers;
TRUNCATE TABLE stg_products;
TRUNCATE TABLE dim_customers;
TRUNCATE TABLE dim_products;
TRUNCATE TABLE fact_sales;
TRUNCATE TABLE inventory_daily;


TRUNCATE TABLE etl_audit;
