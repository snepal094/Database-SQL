# ETL Project: Sales, Customers, Products Pipeline

## Project Overview
This SSIS ETL project automates the extraction, transformation, and loading of **customer, product, and sales data** from staging tables into a data warehouse. It supports:

- Incremental loading of sales transactions
- Slowly changing dimensions for customers and products
- Daily inventory tracking
- Audit logging of ETL runs

The project is implemented using **SQL Server and SSIS**.



---

## Database Objects

### Staging Tables
- `stg_customers`: Contains daily customer data loads  
- `stg_products`: Contains daily product data loads  
- `stg_sales`: Contains daily sales transactions  

### Data Warehouse Tables
- **Fact Table**: `fact_sales` — stores all sales history incrementally  
- **Dimension Tables**:  
  - `dim_customers` — tracks customer attributes using Slowly Changing Dimension Type 2 (SCD2)  
  - `dim_products` — tracks product attributes with SCD2  
- **Inventory Table**: `inventory_daily` — tracks beginning and ending inventory for each product daily  
- **Audit Table**: `etl_audit` — logs ETL package execution details and errors



---

## ETL Logic / Scripts

### 1. Dimension Load
- **`load_dim_products`**:  
  - Performs SCD Type 2 for products  
  - Handles new, updated, discontinued, and reactivated products  
  - Updates total quantity sold from sales  

- **`load_dim_customers`**:  
  - Performs SCD Type 2 for customers  
  - Handles new, updated, inactive customers  

### 2. Inventory Load
- **`load_inventory_daily`**:  
  - Calculates daily **BOH** (Beginning on Hand) and **EOH** (End of Hand) inventory  
  - Considers products with zero sales  
  - Uses sales from staging table and previous inventory records  

### 3. Utility
- **`DollarsToNRS` function**: Converts USD prices to Nepali Rupees  


---