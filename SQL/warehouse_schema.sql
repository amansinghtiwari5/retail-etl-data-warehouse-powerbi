CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50)
);

CREATE TABLE dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(150),
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

CREATE TABLE dim_region (
    region_key INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(50),
    region VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20)
);

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    weekday_name VARCHAR(20)
);

CREATE TABLE fact_sales (
    sales_key INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    customer_key INT,
    product_key INT,
    region_key INT,
    date_key INT,
    revenue DECIMAL(10,2),
    shipping_days INT
);

SHOW TABLES;

INSERT INTO dim_customer (customer_id, customer_name, segment)
SELECT DISTINCT
    customer_id,
    customer_name,
    segment
FROM stg_customers;

SELECT COUNT(*) FROM dim_customer;
SELECT * FROM dim_customer LIMIT 5;

INSERT INTO dim_product (product_id, product_name, category, sub_category)
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category
FROM stg_products;

SELECT COUNT(*) FROM dim_product;

INSERT INTO dim_region (country, region, state, city, postal_code)
SELECT DISTINCT
    country,
    region,
    state,
    city,
    postal_code
FROM stg_regions;

SELECT COUNT(*) FROM dim_region;

INSERT INTO dim_date (
    date_key,
    full_date,
    day,
    month,
    month_name,
    quarter,
    year,
    weekday_name
)
SELECT DISTINCT
    DATE_FORMAT(order_date, '%Y%m%d') AS date_key,
    order_date AS full_date,
    DAY(order_date),
    MONTH(order_date),
    MONTHNAME(order_date),
    QUARTER(order_date),
    YEAR(order_date),
    DAYNAME(order_date)
FROM stg_orders;

SELECT COUNT(*) FROM dim_date;
SELECT * FROM dim_date LIMIT 5;

INSERT INTO fact_sales (
    order_id,
    customer_key,
    product_key,
    region_key,
    date_key,
    revenue,
    shipping_days
)
SELECT
    order_id,
    customer_key,
    product_key,
    region_key,
    date_key,
    revenue,
    shipping_days
FROM (
    SELECT
        o.order_id,
        c.customer_key,
        p.product_key,
        r.region_key,
        d.date_key,
        o.revenue,
        o.shipping_days,
        ROW_NUMBER() OVER (
            PARTITION BY o.order_id, o.product_id, o.order_date
            ORDER BY o.ship_date DESC
        ) AS rn
    FROM stg_orders o
    JOIN dim_customer c ON o.customer_id = c.customer_id
    JOIN dim_product p ON o.product_id = p.product_id
    JOIN dim_region r ON o.region_id = r.region_key
    JOIN dim_date d ON o.order_date = d.full_date
) t
WHERE rn = 1;

ALTER TABLE fact_sales
ADD UNIQUE KEY uq_fact_grain (order_id, product_key, date_key);
    
SELECT COUNT(*) FROM fact_sales;
SELECT * FROM fact_sales LIMIT 5;

SELECT COUNT(*) FROM stg_orders;
SELECT COUNT(*) FROM fact_sales;

SELECT COUNT(*)
FROM fact_sales
WHERE revenue IS NULL
   OR customer_key IS NULL
   OR product_key IS NULL
   OR region_key IS NULL
   OR date_key IS NULL;

SELECT
    (SELECT SUM(revenue) FROM stg_orders) AS staging_revenue,
    (SELECT SUM(revenue) FROM fact_sales) AS warehouse_revenue;

ALTER TABLE fact_sales
ADD COLUMN shipping_lag VARCHAR(20);

UPDATE fact_sales f
JOIN stg_orders s
    ON f.order_id = s.order_id
JOIN dim_date d
    ON f.date_key = d.date_key
SET f.shipping_lag =
    CASE
        WHEN s.ship_date = d.full_date THEN 'Same Day'
        WHEN s.ship_date = DATE_ADD(d.full_date, INTERVAL 1 DAY) THEN 'Next Day'
        ELSE '2+ Days'
    END;
    
    SELECT shipping_lag, COUNT(*) 
FROM fact_sales
GROUP BY shipping_lag;