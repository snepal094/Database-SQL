CREATE OR ALTER PROCEDURE load_dim_products 
AS
BEGIN 

BEGIN TRY
BEGIN TRAN

MERGE INTO dim_products tgt
USING stg_products src
ON (tgt.product_id = src.product_id AND tgt.is_active = 1)

WHEN MATCHED AND (tgt.name<>src.name OR tgt.price<>src.price OR tgt.category<>src.category) THEN 
-- target has related data
-- one or more attributes in the source table differs from the target table
-- hence we make that row inactive, and insert another row with updated values with active status
UPDATE SET tgt.is_active = 0, end_date= GETDATE(), LastUpdatedDateTime = GETDATE()

WHEN NOT MATCHED THEN 
-- target has no data matching the source data (or it matches the product but is inactive)
INSERT (product_id, name, category, price, is_active, start_date, end_date, LastUpdatedDateTime) VALUES
(src.product_id, src.name, src.category, src.price, 1, src.updated_at, NULL, GETDATE())

WHEN NOT MATCHED BY SOURCE THEN 
-- target table has it, but source doesn't -> that product is discontinued. 
-- set isActive=0, and leave the rest as it is
UPDATE SET tgt.is_active = 0, end_date = GETDATE(), LastUpdatedDateTime = GETDATE();

-- inserting a new row for the row that has been put to inactive in the when matched clause
INSERT INTO DIM_PRODUCTS (product_id, name, category, price, is_active, start_date, end_date, LastUpdatedDateTime)
SELECT s.product_id, s.name, s.category, s.price, 1 AS is_active, s.updated_at, NULL, GETDATE()
FROM stg_products as s
LEFT JOIN dim_products as t
ON (s.product_id=t.product_id AND s.name=t.name AND s.category=t.category AND s.price=t.price AND is_active=1)
where t.product_id is NULL;
-- any one condition failing on this ON condition causes the resulting table to have null values in dim_products (t)
-- i.e. if the on condition fails, all fields from t become null
-- so, where condition from t could have any column from t table, like t.name IS NULL or t.price IS NULL, etc.

--When a JOIN fails in a LEFT JOIN, the row still appears,
--but all columns from the second table in the resulting table become NULL.

-- what are the 5 possible conditions?
-- 1. target table and source table both have the product, source table has updated data (when matched + the AND condition)
--    make the existing row inactive and insert the updated data (query following merge query)
-- 2. source table has a row of data target table doesn't (completely new record), so you insert that new row to the target table (when not matched)
-- 3. target table has a certain product that source table doesn't, which means that product has been discontinued, so set isactive to 0 (when not matched by source)
-- 4. nothing has changed but the product still exists -> both the tables will have matching data, leave it untouched on the target table (hence the AND condition in when matched)
-- 5. a discontinued product has been resumed (when not matched handles it)

-- records that are inserted into stg_products are all the existing products in store in that date

-- updating total quantity
WITH total_quantity AS (
    SELECT product_id, SUM(qty) AS tot
    FROM stg_sales
    GROUP BY product_id
)
UPDATE p
SET p.total_qty_sold = ISNULL(p.total_qty_sold, 0) + ISNULL(t.tot, 0)
FROM dim_products p
LEFT JOIN total_quantity t
    ON p.product_id = t.product_id
WHERE p.is_active = 1;

COMMIT TRAN
END TRY

BEGIN CATCH
      ROLLBACK TRAN
END CATCH

END;


GO






CREATE OR ALTER PROCEDURE load_dim_customers
AS
BEGIN 

BEGIN TRY
BEGIN TRAN

MERGE INTO dim_customers tgt
USING stg_customers src
ON (tgt.customer_id=src.customer_id AND tgt.is_active=1)

WHEN MATCHED AND (tgt.first_name<>src.first_name AND
				  tgt.last_name<>src.last_name AND
				  tgt.phonenumber<>src.phonenumber AND
                  tgt.city<>src.city)
THEN
UPDATE SET tgt.is_active=0, tgt.end_date= GETDATE(), tgt.LastUpdatedDateTime= GETDATE()


WHEN NOT MATCHED THEN 
INSERT (customer_id, first_name, last_name, phonenumber, city, is_active, start_date, LastUpdatedDateTime) VALUES
(src.customer_id, src.first_name, src.last_name, src.phonenumber, src.city, 1, src.updated_at, GETDATE())

WHEN NOT MATCHED BY SOURCE THEN 
UPDATE SET tgt.is_active=0, tgt.end_date=GETDATE(), tgt.LastUpdatedDateTime=GETDATE();

INSERT INTO dim_customers (customer_id, first_name, last_name, phonenumber, city, is_active, start_date, LastUpdatedDateTime)
SELECT s.customer_id, s.first_name, s.last_name, s.phonenumber, s.city, 1, s.updated_at, GETDATE()
FROM stg_customers s
LEFT JOIN dim_customers t
ON (s.customer_id=t.customer_id AND s.first_name=t.first_name AND s.last_name=t.last_name AND s.phonenumber=t.phonenumber AND t.is_active=1)
WHERE t.customer_id IS NULL;

COMMIT TRAN
END TRY

BEGIN CATCH
      ROLLBACK TRAN
END CATCH

END;



GO








SELECT * FROM dim_customers;
SELECT * FROM dim_products;
SELECT * FROM stg_products;


GO




CREATE PROCEDURE load_inventory_daily (@last_run_date DATETIME) AS
BEGIN

WITH filtered_stg_sales_by_date AS (
SELECT * FROM stg_sales
WHERE sale_date > @last_run_date
),

total_sold AS (
SELECT p.product_id, s.sale_date, ISNULL(sum(s.qty), 0) as qty_sold 
FROM dim_products as p 
LEFT JOIN filtered_stg_sales_by_date as s
on p.product_id=s.product_id 
WHERE p.is_active = 1
GROUP BY p.product_id, s.sale_date
),

-- total_sold: Generates a row for every active product for today — even if a product had zero sales.
-- even if the stg_sales table doesn't have the data for a product, we update inventory_daily for each product daily
-- hence the need to (left) join dim_products (which contains all products) with stg_sales
-- if there is no sale of a product on that day (stg_sales has no data for it), qty_sold=0
-- filters out inactive products, and the product sales data before the last run date (we are concerned with that day's data only)
-- Only include currently active products, ignoring historical or discontinued ones (is_active = 0)
-- here, the products not present in stg_sales will have NULL values in s.sale_date, which is handled below in calc_boh

calc_boh as(
SELECT ISNULL(a.sale_date, DATEADD(day, +1, b.inventory_date)) AS sale_date, 
       a.product_id, 
	   ISNULL(b.eoh, 100) as latest_boh, 
	   a.qty_sold AS qty_sold
FROM total_sold a
LEFT JOIN inventory_daily b
ON a.product_id = b.product_id AND b.inventory_date = DATEADD(day, -1, a.sale_date)   
-- “Find yesterday’s inventory record for this product.”
),

-- calc_boh
-- If the product had a sale today → use its actual sale_date.
-- If it had zero sales today → use yesterday’s date + 1 (which equals today's date).
-- here, the select clause contains columns that are all related to the current date (date of which the data is being processed in the ETL pipeline)
-- even if stg_sales doesn't contain product data and total_sold gives NULL sale_date, 
-- we create fresh data for those products by incrementing the inventory_date by 1
-- however, to calculate the boh for that day, we need the value of eoh of that product of the previous day
-- hence the ON clause that matches the date of the PREVIOUS day (day BEFORE the data that the pipeline is processing), for new_boh = old_eoh


calc_eoh as (
SELECT sale_date as inventory_date, product_id, latest_boh as boh, latest_boh - qty_sold as eoh
FROM calc_boh)


INSERT INTO inventory_daily(product_id, inventory_date, boh, eoh)
SELECT product_id, inventory_date, boh, eoh
FROM calc_eoh;

END;



GO


select * from dim_products;
select * from inventory_daily;

select DATEADD(day, 1, '2025-10-31');


GO

CREATE or ALTER FUNCTION DollarsToNRS(@price int)  
RETURNS int
AS 
BEGIN
    RETURN @price*140; 
END;

