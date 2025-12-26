-- TEST CASE 1: ROW COUNT RECONCILIATION
-- Staging row count
SELECT COUNT(*) AS staging_count FROM stg_orders;

-- Warehouse row count
SELECT COUNT(*) AS fact_count FROM fact_sales;

-- TEST CASE 2: NULL VALUE CHECK

SELECT COUNT(*) AS null_records
FROM fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL
   OR region_key IS NULL
   OR date_key IS NULL
   OR revenue IS NULL;

-- TEST CASE 3: DUPLICATE CHECK (FACT TABLE)

SELECT
    order_id,
    product_key,
    date_key,
    COUNT(*)
FROM fact_sales
GROUP BY order_id, product_key, date_key
HAVING COUNT(*) > 1;

-- TEST CASE 4: BUSINESS METRIC VALIDATION (CRITICAL)

SELECT
    ROUND(SUM(revenue), 2) AS warehouse_revenue
FROM fact_sales;

SELECT
    ROUND(SUM(revenue), 2) AS staging_revenue
FROM stg_orders;

-- TEST CASE 5: DATE CONSISTENCY CHECK

SELECT COUNT(*)
FROM fact_sales f
LEFT JOIN dim_date d
ON f.date_key = d.date_key
WHERE d.date_key IS NULL;

-- TEST CASE 6: DIMENSION LOOKUP VALIDATION

SELECT COUNT(*)
FROM fact_sales f
LEFT JOIN dim_customer c
ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;
